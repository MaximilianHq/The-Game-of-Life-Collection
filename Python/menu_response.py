def MenuBorder(text:str):
    border = "================="
    return f"\n{border}\n{text}\n{border}\n"

def InvalidInput(error, expected_input:str = ""):
    print(f"Invalid input: {error}. \
          Please enter a valid value! {expected_input}")