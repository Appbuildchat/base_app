import os
import re
import csv
import glob
import pandas as pd

def process_user_folder_filtered():
    current_dir = os.getcwd()
    input_dir = os.path.join(current_dir, "input")
    
    # Find CSV files matching pattern *_list_P_output.csv in input directory
    csv_pattern = os.path.join(input_dir, "*_list_P_output.csv")
    csv_files = glob.glob(csv_pattern)
    
    if not csv_files:
        raise ValueError("input 폴더에서 *_list_P_output.csv 파일을 찾을 수 없습니다.")
    
    # Use the first CSV file found
    csv_file_path = csv_files[0]
    csv_filename = os.path.basename(csv_file_path)
    
    # Extract user_id from filename pattern: username@domain.com_list_P_output.csv
    if '_list_P_output.csv' in csv_filename:
        user_id_full = csv_filename.replace('_list_P_output.csv', '')
        user_id = user_id_full.split('@')[0] if '@' in user_id_full else user_id_full
    else:
        user_id = "unknown"

    P_first_output = []

    # Try multiple encodings for CSV file
    file_read_success = False
    for encoding in ['utf-8', 'cp949', 'euc-kr']:
        try:
            with open(csv_file_path, mode='r', encoding=encoding) as file:
                reader = csv.reader(file)  
                for row in reader:
                    if row and row[0].strip(): 
                        P_first_output = row[0]
                        break
            print(f"✅ CSV file loaded with {encoding} encoding")
            file_read_success = True
            break
        except UnicodeDecodeError:
            continue
    
    if not file_read_success:
        raise Exception("Could not read CSV file with any supported encoding (utf-8, cp949, euc-kr)")

    return user_id, P_first_output


def clean_dart_code(code_content: str) -> str:
    """
    Remove markdown code block markers from generated Dart code
    """
    # Remove ```dart at the beginning
    if code_content.strip().startswith('```dart'):
        code_content = code_content.replace('```dart', '', 1)
    
    # Remove ``` at the end  
    if code_content.strip().endswith('```'):
        code_content = code_content.rsplit('```', 1)[0]
    
    return code_content.strip()

