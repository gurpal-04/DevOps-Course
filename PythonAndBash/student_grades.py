
students = {
    "Alice": "A",
    "Bob": "B"
}

while True:
    print("\n1. Add Student")
    print("2. Update Grade")
    print("3. Print All Grades")
    print("4. Exit")

    choice = input("Enter your choice: ")

    if choice == "1":
        name = input("Enter student name: ")
        grade = input("Enter grade: ")
        students[name] = grade
        print(f"{name} added successfully!")

    elif choice == "2":
        name = input("Enter student name to update: ")
        if name in students:
            new_grade = input("Enter new grade: ")
            students[name] = new_grade
            print(f"{name}'s grade updated to {new_grade}")
        else:
            print("Student not found!")

    elif choice == "3":
        print("\nAll Student Grades:")
        for name, grade in students.items():
            print(f"{name}: {grade}")

    elif choice == "4":
        print("Exiting...")
        break

    else:
        print("Invalid choice!")
