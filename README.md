#run before making a new executable
pip install -r requirements.txt

#to make a new executable
python -m PyInstaller --onefile --windowed split_dat_to_files.py
