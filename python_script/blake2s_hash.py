import sys
import serial
import os

# Constants
MAX_KEY_LENGTH = 32
BLOCK_SIZE = 64
# Internal parameter which is practically constant
BAUDRATE = 2000000


def exit_with_error(error_msg):
    print(f"\n⚠️  ERROR: ")
    print(f"   {error_msg}")
    sys.exit("Hashing cancelado.")


def procesar_hash(message_path, digest_size_bytes, key_path, use_key):

    def format_hex_digest(hex_str):  # format a hex string into groups of 8 characters (4 bytes)
        return ' '.join([hex_str[i:i + 8] for i in range(0, len(hex_str), 8)])

    def read_key():
        key_file_size = os.stat(key_path).st_size
        if key_file_size > MAX_KEY_LENGTH:
            exit_with_error(
                "La clave es demasiado larga. Recuerda: La clave puede tener una longitud máxima de 32 bytes")
        elif key_file_size == 0:
            exit_with_error("El archivo de claves está vacío."
                            "Escriba algo en el archivo de clave o desactive la opción de hashing con clave")

        with open(key_path, "r", encoding="utf-8") as key_file:
            key_utf8 = key_file.read()
            print(f"Tamaño de clave: {key_file_size} bytes")
            print(f'Clave (UTF-8) : \"{key_utf8}\"')
        return bytes(key_utf8, "utf-8")

    def formato_tiempo(segundos):
        if segundos < 0.003:
            return f"{segundos * 1e6:.0f} μs"
        elif segundos < 0.1:
            return f"{segundos * 1000:.1f} ms"
        elif segundos < 1.2:
            return f"{segundos * 1000:.0f} ms"
        elif segundos < 120:
            return f"{segundos:.1f} s"
        elif segundos < 7200:
            minutos = int(segundos // 60)
            segs = segundos % 60
            return f"{minutos} min: {segs:.1f} s"
        else:
            horas = int(segundos // 3600)
            minutos = int((segundos % 3600) // 60)
            segs = segundos % 60
            return f"{horas} h: {minutos} min: {segs:.0f} s"

    print(f"\n⚙️ RESUMEN DE PARÁMETROS")
    print(f"------------------------------")

    # Read the message file
    with open(message_path, "rb") as message_file:
        message = message_file.read()
    #    if not message:
    #        exit_with_error("El archivo del mensaje está vacío -- no hay nada que enviar")

    message_size_bytes = len(message) + (BLOCK_SIZE if use_key else 0)

    # Read and process the key if needed
    key = read_key() if use_key else None
    key_size_bytes = len(key) if use_key else 0

    if not message and not use_key:
        # Si el mensaje está VACÍO Y NO se usa clave
        exit_with_error("Archivo vacío sin clave no es válida")

    print(f"Tamaño de mensaje: {message_size_bytes} bytes")
    print(f"Tamaño de Digest: {digest_size_bytes} bytes")

    # Prepare data for transmission
    # Here, I use 'list comprehension', a 'Pythonic' way to create lists inline.
    # It replaces the more verbose loop below, which was my original approach.
    # Although the shorthand feels less intuitive to me, I've adopted it here following suggestions
    # to make the code more aligned with Python best practices.

    # Original loop for comparison (commented out):
    # message_blocks = []
    # for i in range(0, len(message), BLOCK_SIZE):
    #     block = bytes(message[i:i+BLOCK_SIZE])
    #     message_blocks.append(block)

    # in the marginal case the message is empty, then there's no need to pad anything
    if message:
        message_blocks = [message[i:i + BLOCK_SIZE] for i in range(0, len(message), BLOCK_SIZE)]
        # Padding the last block if it does not fill the entire BLOCK_SIZE
        if len(message_blocks[-1]) != BLOCK_SIZE:
            message_blocks[-1] += bytes(BLOCK_SIZE - len(message_blocks[-1]))
    else:
        message_blocks = []

    if use_key:
        key += bytes(BLOCK_SIZE - key_size_bytes)  # Pads the key into a full block

    # Convert sizes to byte arrays
    message_size_bytes_bytearray = message_size_bytes.to_bytes(8, byteorder='big')
    key_size_bytes_bytearray = key_size_bytes.to_bytes(1, byteorder='big')
    digest_size_bytes_bytearray = digest_size_bytes.to_bytes(1, byteorder='big')

    # some stats, curiousity
    num_bloques = 1 + len(message_blocks)
    if use_key:
        num_bloques = num_bloques + 1
    total_num_bytes = num_bloques * BLOCK_SIZE
    transmission_time = total_num_bytes / (BAUDRATE / 10)

    # Serial communication
    print("\n🔌 COMUNICACIÓN UART CON FPGA")
    print("------------------------------")
    print(f"Baudrate: {BAUDRATE} bps")
    print(f"Bloques a enviar: {num_bloques}")
    print(f"Tiempo de transmisión: {formato_tiempo(transmission_time)}")
    ser = serial.Serial(port='COM3', baudrate=BAUDRATE, timeout=1)
    print(f"Comunicación establecida con: {ser.name}.")
    # Next 8 lines send the 0th block, the 'Bloque de Parámetros de Inicialización'.
    # This way, I reuse the simple VHDL interfaces inside the FPGA.
    ser.write(message_size_bytes_bytearray)  # Message size
    ser.write(b'VM')  # Meaningless padding added just so I wouldn't get confused by Endianness.
    if use_key:
        ser.write(key_size_bytes_bytearray)
    else:
        ser.write(b'\x00')  # If there's no key, an empty byte has to go in its place. Could be rewritten more elegantly
    ser.write(digest_size_bytes_bytearray)
    ser.write(b'It does not really matter what you type here, friend')  # Further padding, 52 bytes to be precise.

    print(f"Bloque de parámetros enviado.")
    if use_key:
        ser.write(key)
        print(f"Bloque de clave enviado.")

    print(f"Enviando bloques de mensaje...")
    for block in message_blocks:
        ser.write(block)

    # Receive and handle the digest
    in_bin = ser.read(32)
    print(f"Se ha cerrado {ser.name}.")

    # digest handling
    in_hex = hex(int.from_bytes(in_bin, byteorder='big'))[2:]
    hash_length_padding = 64
    in_hex_padded = in_hex.zfill(hash_length_padding)

    # the circuit will always return a string of fixed length, so it rests upon
    # this instruction to chop off the irrelevant bits
    in_hex_truncated = in_hex_padded[:2 * digest_size_bytes]

    print("\n✅ Resultado recibido")
    print(f"------------------------------")
    # if you wanna see the rest of the digest, uncomment this
    # print(f'Digest Preliminar (32 bytes):\n{format_hex_digest(in_hex_padded)}')
    print(f'Digest BLAKE2s recibido:\n{format_hex_digest(in_hex_truncated)}')
    print("======== ======== ======== ======== ======== ======== ======== ========")


def expo_mode():
    print("======== ======== ======== ======== ======== ======== ======== ========")
    print("📁 ENTRADA DE DATOS")
    message_path = input("Archivo a hashear: ") or "sleepy_betta_splendens.jpg"
    yn_answer = input("¿Usar clave? (s/n): ").strip()
    # Detecta 's', 'si', 'sí', 'y', 'yes' en cualquier combinación
    use_key = yn_answer.startswith(('s', 'y', 'S', 'Y'))
    if use_key:
        key_path = input("Archivo de clave: ") or "blake2s_key.txt"
    else:
        key_path = None
    digest_size = int(input("Tamaño de digest (bytes): ") or "32")

    procesar_hash(message_path, digest_size, key_path, use_key)


def cli_mode():
    # Simple parsing, so i can incorporate this as part of a larger tool
    # "Uso: python blake2s_hash.py <archivo a hashear> <tamaño digest> <archivo de llave>"
    # print()
    # so this cli_mode will always happen as long as there's a single argument,
    # which means the first argument will always be the message to be hashed
    message_path = sys.argv[1]

    # Valores default, igualito que en VHDL...
    key_path = None
    digest_size = 32

    if len(sys.argv) == 2:
        use_key = False

    elif len(sys.argv) == 3:
        use_key = False
        digest_size = int(sys.argv[2])

    elif len(sys.argv) == 4:
        use_key = True
        digest_size = int(sys.argv[2])
        key_path = sys.argv[3]

    else:
        exit_with_error("Demasiados argumentos."
                        "Uso: python blake2s_hash.py <archivo_a_hashear> <tamaño_del_digest> <archivo_de_clave>")

    procesar_hash(message_path, digest_size, key_path, use_key)


if __name__ == "__main__":
    # based on the number of arguments, we run the script in two ways.
    # Si corremos el script sin argumentos, entramos en un modo interactivo
    # Si corremos el script con al menos un argumento, entramos en modo de comando
    # El objeto es exponer el trabajo creado y
    # permitir la fácil integración de este script con cualquier herramienta

    if len(sys.argv) == 1:
        print("🚀 LANZANDO DEMOSTRACIÓN BLAKE2s FPGA")
        expo_mode()
    else:
        print("Corriendo interfaz con argumentos de consola...")
        cli_mode()
