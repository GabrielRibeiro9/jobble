import os
import re

lib_dir = r"c:\projects\flutter_tcc\lib"

for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart') and 'app_colors.dart' not in f and 'app_theme.dart' not in f and 'theme_cubit.dart' not in f:
            filepath = os.path.join(root, f)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
            
            if 'AppColors' in content:
                new_lines = []
                for line in content.split('\n'):
                    if 'AppColors.' in line:
                        # Substitui AppColors.xxx -> context.colors.xxx
                        line = re.sub(r'AppColors\.(\w+)', r'context.colors.\1', line)
                        
                        # Remove a palavra 'const ' se houver algo dinâmico como context.colors
                        if 'context.colors' in line:
                            line = line.replace('const ', '')
                    new_lines.append(line)
                
                new_content = '\n'.join(new_lines)
                
                # Check for import
                import_statement = "import 'package:flutter_tcc/core/theme/app_colors.dart';"
                if import_statement not in new_content:
                    lines = new_content.split('\n')
                    for i, l in enumerate(lines):
                        if l.startswith('import '):
                            lines.insert(i+1, import_statement)
                            break
                    new_content = '\n'.join(lines)
                
                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(new_content)
                print(f"Updated {filepath}")
