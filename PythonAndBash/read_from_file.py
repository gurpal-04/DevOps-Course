filename = input("Enter the filename to read (example: notes.txt or data.csv): ")

try:
    file = open(filename, "r")
    content = file.read()
    file.close()
    print("\nFile Content:\n")
    print(content)
except FileNotFoundError:
    print(f"Error: The file '{filename}' does not exist.")