import os
import re
import tkinter as tk
from tkinter import filedialog

def select_dat_file():
    """Opens a dialog to select a .dat file."""
    root = tk.Tk()
    root.withdraw()
    root.attributes('-topmost', True)
    file_path = filedialog.askopenfilename(
        parent=root,
        title="Select a .dat file to split",
        filetypes=[("DAT files", "*.dat")]
    )
    root.attributes('-topmost', False)
    if not file_path:
        print("File selection was canceled.")
        return None
    return file_path

def select_output_directory():
    """Opens a dialog to select a directory for the output files."""
    root = tk.Tk()
    root.withdraw()
    root.attributes('-topmost', True)
    output_path = filedialog.askdirectory(
        parent=root,
        title="Select a folder for the 'resulting_files'"
    )
    root.attributes('-topmost', False)
    if not output_path:
        print("Folder selection was canceled.")
        return None
    return output_path

def split_dat_file_to_prg(input_file_path, output_dir_base):
    """
    Reads a .dat file, splits it into blocks based on 'CREATE PROGRAM'/'DROP PROGRAM'
    and 'END GO' markers, and saves each block as a separate .prg file in a 'resulting_files' subdirectory.
    """
    output_dir = os.path.join(output_dir_base, "resulting_files")

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
        print(f"Created directory: {output_dir}")

    blocks_created_count = 0
    current_block_content = []
    in_block = False
    block_name = ""

    try:
        with open(input_file_path, 'r', encoding='utf-8', errors='ignore') as file:
            for line in file:
                # A new block starts with 'CREATE PROGRAM' or 'DROP PROGRAM'
                if 'CREATE PROGRAM' in line or 'DROP PROGRAM' in line:
                    if in_block and current_block_content:
                        # If we find a new block start but the previous block was not 'closed' by 'END GO',
                        # it indicates a potential issue in the file structure. For now, we'll just log this.
                        print(f"Warning: New block started for '{block_name}' before previous block ended.")

                    in_block = True
                    # Extract program name, assuming it's the third word on the line
                    parts = line.strip().split()
                    if len(parts) > 2:
                        block_name = parts[2]
                    else:
                        # Fallback for unusually formatted lines
                        block_name = f"unnamed_block_{blocks_created_count + 1}"
                    current_block_content = [line]
                
                # An existing block can continue with more lines
                elif in_block:
                    current_block_content.append(line)

                    # A block ends with 'END GO'
                    if 'END GO' in line:
                        # Sanitize block_name to create a valid filename
                        sanitized_name = re.sub(r'[:/\\?*|"<>]', '_', block_name)
                        output_filename = f"{sanitized_name}.prg"
                        output_path = os.path.join(output_dir, output_filename)

                        # Write the collected lines for the block to its own file
                        with open(output_path, 'w', encoding='utf-8') as block_file:
                            block_file.writelines(current_block_content)
                        
                        blocks_created_count += 1
                        
                        # Reset for the next block
                        in_block = False
                        current_block_content = []
                        block_name = ""

    except IOError as e:
        print(f"Error reading file {input_file_path}: {e}")

    print(f"\nProcessing complete. {blocks_created_count} .prg files have been created in '{output_dir}'.")

def main():
    """Main function to run the script."""
    input_file = select_dat_file()
    if input_file:
        output_dir_base = select_output_directory()
        if output_dir_base:
            print(f"Processing file: {input_file}")
            print(f"Output will be saved in: {os.path.join(output_dir_base, 'resulting_files')}")
            split_dat_file_to_prg(input_file, output_dir_base)

if __name__ == "__main__":
    main()
