#!/usr/bin/env python3
"""
MultiPurposeApp Flowchart to PDF Converter
Converts APP_FLOWCHART.md with Mermaid diagrams to a PDF with graphical visuals
"""

import re
import os
import base64
import urllib.parse
from pathlib import Path

def extract_mermaid_diagrams(markdown_content):
    """Extract all Mermaid diagrams from markdown content"""
    pattern = r'```mermaid\s*\n(.*?)\n```'
    diagrams = re.findall(pattern, markdown_content, re.DOTALL)
    return diagrams

def create_mermaid_url(diagram_code, theme='default'):
    """Create a URL for rendering Mermaid diagram"""
    encoded_diagram = urllib.parse.quote(diagram_code)
    return f"https://mermaid.ink/img/{base64.b64encode(diagram_code.encode()).decode()}?type=png&theme={theme}"

def create_html_document(markdown_content, diagrams):
    """Create an HTML document with rendered diagrams"""
    
    html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MultiPurposeApp - User Flow Chart</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f8f9fa;
        }
        .container {
            background-color: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
            margin-bottom: 30px;
        }
        h2 {
            color: #34495e;
            margin-top: 40px;
            margin-bottom: 20px;
            border-left: 4px solid #3498db;
            padding-left: 15px;
        }
        h3 {
            color: #2c3e50;
            margin-top: 30px;
            margin-bottom: 15px;
        }
        .flowchart-container {
            text-align: center;
            margin: 30px 0;
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }
        .flowchart-image {
            max-width: 100%;
            height: auto;
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .flowchart-caption {
            margin-top: 15px;
            font-style: italic;
            color: #6c757d;
            font-size: 14px;
        }
        .section {
            margin-bottom: 40px;
            page-break-inside: avoid;
        }
        .metadata {
            background-color: #e3f2fd;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 30px;
            border-left: 4px solid #2196f3;
        }
        .metadata p {
            margin: 5px 0;
            font-size: 14px;
        }
        .user-journey {
            background-color: #f3e5f5;
            padding: 20px;
            border-radius: 6px;
            margin: 20px 0;
            border-left: 4px solid #9c27b0;
        }
        .user-journey h3 {
            color: #7b1fa2;
            margin-top: 0;
        }
        @media print {
            body {
                background-color: white;
                margin: 0;
                padding: 20px;
            }
            .container {
                box-shadow: none;
                padding: 20px;
            }
            .flowchart-container {
                page-break-inside: avoid;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>MultiPurposeApp - User Flow Chart</h1>
        
        <div class="metadata">
            <p><strong>Last Updated:</strong> July 31, 2025</p>
            <p><strong>Version:</strong> 1.0.0 (MVP)</p>
            <p><strong>Document Type:</strong> User Flow Documentation</p>
        </div>

        <div class="section">
            <h2>Overview</h2>
            <p>This document provides a comprehensive flowchart of all possible user flows in the MultiPurposeApp, from initial launch to all possible user interactions and navigation paths.</p>
        </div>
"""

    # Split markdown content into sections
    sections = markdown_content.split('## ')
    
    diagram_index = 0
    
    for section in sections[1:]:  # Skip the first empty section
        lines = section.strip().split('\n')
        section_title = lines[0]
        section_content = '\n'.join(lines[1:])
        
        html_template += f"""
        <div class="section">
            <h2>{section_title}</h2>
"""
        
        # Check if this section has a diagram
        if diagram_index < len(diagrams):
            diagram = diagrams[diagram_index]
            mermaid_url = create_mermaid_url(diagram)
            
            html_template += f"""
            <div class="flowchart-container">
                <img src="{mermaid_url}" alt="Flowchart: {section_title}" class="flowchart-image">
                <div class="flowchart-caption">Figure {diagram_index + 1}: {section_title}</div>
            </div>
"""
            diagram_index += 1
        
        # Add section content (excluding mermaid blocks)
        content_lines = []
        in_mermaid_block = False
        
        for line in section_content.split('\n'):
            if line.strip().startswith('```mermaid'):
                in_mermaid_block = True
                continue
            elif line.strip().startswith('```'):
                in_mermaid_block = False
                continue
            elif not in_mermaid_block:
                content_lines.append(line)
        
        section_text = '\n'.join(content_lines).strip()
        if section_text:
            # Convert markdown to simple HTML
            section_text = section_text.replace('**', '<strong>').replace('**', '</strong>')
            section_text = section_text.replace('*', '<em>').replace('*', '</em>')
            section_text = section_text.replace('\n\n', '</p><p>')
            if section_text:
                html_template += f"<p>{section_text}</p>"
        
        html_template += """
        </div>
"""
    
    # Add footer
    html_template += """
        <div class="section">
            <hr style="margin: 40px 0; border: none; border-top: 2px solid #e9ecef;">
            <p style="text-align: center; color: #6c757d; font-size: 14px;">
                <strong>MultiPurposeApp v1.0.0</strong> - Comprehensive user flow documentation for all possible navigation paths and interactions.<br>
                <em>Last Updated: July 31, 2025</em>
            </p>
        </div>
    </div>
</body>
</html>
"""
    
    return html_template

def main():
    """Main function to convert markdown to PDF"""
    
    # Read the markdown file
    markdown_file = "APP_FLOWCHART.md"
    if not os.path.exists(markdown_file):
        print(f"Error: {markdown_file} not found!")
        return
    
    with open(markdown_file, 'r', encoding='utf-8') as f:
        markdown_content = f.read()
    
    # Extract Mermaid diagrams
    diagrams = extract_mermaid_diagrams(markdown_content)
    print(f"Found {len(diagrams)} Mermaid diagrams")
    
    # Create HTML document
    html_content = create_html_document(markdown_content, diagrams)
    
    # Save HTML file
    html_file = "APP_FLOWCHART.html"
    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print(f"Created HTML file: {html_file}")
    
    # Try to convert to PDF using wkhtmltopdf if available
    try:
        import subprocess
        result = subprocess.run(['which', 'wkhtmltopdf'], capture_output=True, text=True)
        if result.returncode == 0:
            pdf_file = "APP_FLOWCHART.pdf"
            cmd = [
                'wkhtmltopdf',
                '--page-size', 'A4',
                '--margin-top', '20mm',
                '--margin-bottom', '20mm',
                '--margin-left', '20mm',
                '--margin-right', '20mm',
                '--enable-local-file-access',
                html_file,
                pdf_file
            ]
            subprocess.run(cmd, check=True)
            print(f"Created PDF file: {pdf_file}")
        else:
            print("wkhtmltopdf not found. Please install it to generate PDF:")
            print("  brew install wkhtmltopdf")
            print(f"Or open {html_file} in a browser and print to PDF")
    except ImportError:
        print("subprocess module not available")
        print(f"Please open {html_file} in a browser and print to PDF")
    except subprocess.CalledProcessError as e:
        print(f"Error creating PDF: {e}")
        print(f"Please open {html_file} in a browser and print to PDF")

if __name__ == "__main__":
    main() 