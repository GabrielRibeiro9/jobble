import os
import subprocess

print("Running flutter analyze...")
result = subprocess.run(['flutter', 'analyze'], capture_output=True, text=True, cwd=r'c:\projects\flutter_tcc', shell=True)
output = result.stdout + result.stderr

changes_made = 0
for line in output.split('\n'):
    if 'Invalid constant value' in line or 'must be constants' in line:
        # Format usually:   info • The values in a const list literal must be constants • lib\features\home\presentation\pages\home_page.dart:839:11 • non_constant_list_element
        # or           error • Invalid constant value • lib\features\home\presentation\pages\home_page.dart:201:17 • pattern
        parts = line.split(' • ')
        if len(parts) >= 3:
            file_info = parts[2].strip()
            # file_info usually "lib\foo.dart:123:45"
            file_parts = file_info.split(':')
            if len(file_parts) >= 2:
                filepath = os.path.join(r'c:\projects\flutter_tcc', file_parts[0])
                try:
                    line_num = int(file_parts[1]) - 1
                except:
                    continue
                
                if os.path.exists(filepath):
                    with open(filepath, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                    
                    if line_num < len(lines):
                        if 'const ' in lines[line_num]:
                            lines[line_num] = lines[line_num].replace('const ', '')
                            with open(filepath, 'w', encoding='utf-8') as f:
                                f.writelines(lines)
                            print(f"Removed const in {filepath}:{line_num+1}")
                            changes_made += 1

print(f"Done. Made {changes_made} changes.")
