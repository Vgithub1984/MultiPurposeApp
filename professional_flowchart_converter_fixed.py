#!/usr/bin/env python3
"""
Professional MultiPurposeApp Flowchart Converter (Fixed)
Uses mmdc (Mermaid CLI) to generate high-quality diagrams and create professional PDF
"""

import re
import os
import subprocess
import tempfile
import shutil
from pathlib import Path
import base64

class ProfessionalFlowchartConverter:
    def __init__(self):
        self.output_dir = "flowchart_output_professional"
        self.diagrams_dir = f"{self.output_dir}/diagrams"
        self.theme = "default"
        self.format = "png"
        
    def setup_directories(self):
        """Create output directories"""
        os.makedirs(self.output_dir, exist_ok=True)
        os.makedirs(self.diagrams_dir, exist_ok=True)
        
    def extract_mermaid_diagrams(self, markdown_content):
        """Extract all Mermaid diagrams from markdown content"""
        pattern = r'```mermaid\s*\n(.*?)\n```'
        diagrams = re.findall(pattern, markdown_content, re.DOTALL)
        return diagrams
    
    def generate_diagram_with_mmdc(self, diagram_code, diagram_name, index):
        """Generate diagram using mmdc (Mermaid CLI) with correct syntax"""
        try:
            # Create temporary file for diagram code
            with tempfile.NamedTemporaryFile(mode='w', suffix='.mmd', delete=False) as temp_file:
                temp_file.write(diagram_code)
                temp_file_path = temp_file.name
            
            # Output file path
            output_file = f"{self.diagrams_dir}/diagram_{index:02d}_{diagram_name}.png"
            
            # mmdc command with correct syntax
            cmd = [
                'mmdc',
                '-i', temp_file_path,
                '-o', output_file,
                '-t', self.theme,
                '-e', 'png',
                '-w', '1200',
                '-H', '800',
                '-s', '2',
                '-b', 'white'
            ]
            
            print(f"Generating diagram {index + 1}: {diagram_name}")
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            # Clean up temp file
            os.unlink(temp_file_path)
            
            if result.returncode == 0 and os.path.exists(output_file):
                print(f"✅ Generated: {output_file}")
                return output_file
            else:
                print(f"❌ Failed to generate {diagram_name}: {result.stderr}")
                return None
                
        except Exception as e:
            print(f"Error generating diagram {diagram_name}: {e}")
            return None
    
    def create_professional_html(self, markdown_content, diagram_files):
        """Create professional HTML document with generated diagrams"""
        
        html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MultiPurposeApp - Professional User Flow Chart</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.7;
            color: #1a202c;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 16px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 10px;
            background: linear-gradient(45deg, #3498db, #9b59b6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        
        .header .subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
            font-weight: 300;
        }
        
        .metadata {
            background: linear-gradient(135deg, #e3f2fd 0%, #f3e5f5 100%);
            padding: 30px 40px;
            border-bottom: 1px solid #e1e8ed;
        }
        
        .metadata-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .metadata-item {
            background: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        .metadata-item strong {
            color: #2c3e50;
            display: block;
            margin-bottom: 5px;
        }
        
        .content {
            padding: 40px;
        }
        
        .section {
            margin-bottom: 60px;
            page-break-inside: avoid;
        }
        
        .section h2 {
            font-size: 1.8rem;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 25px;
            padding-bottom: 10px;
            border-bottom: 3px solid #3498db;
            position: relative;
        }
        
        .section h2::before {
            content: '';
            position: absolute;
            bottom: -3px;
            left: 0;
            width: 60px;
            height: 3px;
            background: linear-gradient(45deg, #3498db, #9b59b6);
        }
        
        .section h3 {
            font-size: 1.3rem;
            font-weight: 500;
            color: #34495e;
            margin: 25px 0 15px 0;
        }
        
        .flowchart-container {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 12px;
            padding: 30px;
            margin: 30px 0;
            border: 1px solid #dee2e6;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        
        .flowchart-image {
            width: 100%;
            height: auto;
            border-radius: 8px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.15);
            transition: transform 0.3s ease;
        }
        
        .flowchart-image:hover {
            transform: scale(1.02);
        }
        
        .flowchart-caption {
            text-align: center;
            margin-top: 20px;
            font-weight: 500;
            color: #495057;
            font-size: 1rem;
            padding: 10px;
            background: white;
            border-radius: 6px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .section-content {
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            margin-top: 20px;
        }
        
        .section-content p {
            margin-bottom: 15px;
            color: #495057;
        }
        
        .user-journey {
            background: linear-gradient(135deg, #f3e5f5 0%, #e8eaf6 100%);
            padding: 25px;
            border-radius: 12px;
            margin: 25px 0;
            border-left: 4px solid #9c27b0;
        }
        
        .user-journey h3 {
            color: #7b1fa2;
            margin-top: 0;
        }
        
        .footer {
            background: linear-gradient(135deg, #2c3e50 0%, #34495e 100%);
            color: white;
            padding: 30px 40px;
            text-align: center;
        }
        
        .footer p {
            margin: 5px 0;
            opacity: 0.9;
        }
        
        @media print {
            body {
                background: white;
                padding: 0;
            }
            
            .container {
                box-shadow: none;
                border-radius: 0;
            }
            
            .header {
                background: #2c3e50 !important;
                -webkit-print-color-adjust: exact;
                color-adjust: exact;
            }
            
            .flowchart-container {
                page-break-inside: avoid;
                background: #f8f9fa !important;
                -webkit-print-color-adjust: exact;
                color-adjust: exact;
            }
            
            .section {
                page-break-inside: avoid;
            }
        }
        
        @media (max-width: 768px) {
            .header h1 {
                font-size: 2rem;
            }
            
            .content {
                padding: 20px;
            }
            
            .metadata-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>MultiPurposeApp</h1>
            <p class="subtitle">Professional User Flow Chart Documentation</p>
        </div>
        
        <div class="metadata">
            <div class="metadata-grid">
                <div class="metadata-item">
                    <strong>Document Type</strong>
                    User Flow Documentation
                </div>
                <div class="metadata-item">
                    <strong>Version</strong>
                    1.0.0 (MVP)
                </div>
                <div class="metadata-item">
                    <strong>Last Updated</strong>
                    July 31, 2025
                </div>
                <div class="metadata-item">
                    <strong>Generated With</strong>
                    Mermaid CLI + Professional Tools
                </div>
            </div>
        </div>

        <div class="content">
            <div class="section">
                <h2>Overview</h2>
                <div class="section-content">
                    <p>This document provides a comprehensive flowchart of all possible user flows in the MultiPurposeApp, from initial launch to all possible user interactions and navigation paths. Each diagram has been professionally rendered using Mermaid CLI for optimal quality and clarity.</p>
                </div>
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
            if diagram_index < len(diagram_files) and diagram_files[diagram_index]:
                diagram_file = diagram_files[diagram_index]
                relative_path = os.path.relpath(diagram_file, self.output_dir)
                
                html_template += f"""
                <div class="flowchart-container">
                    <img src="{relative_path}" alt="Professional Flowchart: {section_title}" class="flowchart-image">
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
                    html_template += f"""
                <div class="section-content">
                    <p>{section_text}</p>
                </div>
"""
            
            html_template += """
            </div>
"""
        
        # Add footer
        html_template += """
        </div>
        
        <div class="footer">
            <p><strong>MultiPurposeApp v1.0.0</strong></p>
            <p>Comprehensive user flow documentation for all possible navigation paths and interactions</p>
            <p><em>Professionally generated with Mermaid CLI - Last Updated: July 31, 2025</em></p>
        </div>
    </div>
</body>
</html>
"""
        
        return html_template
    
    def generate_pdf_with_chrome(self, html_file, pdf_file):
        """Generate PDF using Chrome headless with professional settings"""
        try:
            # Get absolute path
            html_abs_path = os.path.abspath(html_file)
            
            # Find Chrome executable
            chrome_paths = [
                '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
                'google-chrome',
                'chromium-browser'
            ]
            
            chrome_path = None
            for path in chrome_paths:
                result = subprocess.run(['which', path], capture_output=True, text=True)
                if result.returncode == 0:
                    chrome_path = result.stdout.strip()
                    break
            
            if not chrome_path:
                # Try direct path check
                for path in chrome_paths:
                    if os.path.exists(path):
                        chrome_path = path
                        break
            
            if not chrome_path:
                print("❌ Chrome not found. Please install Google Chrome.")
                return False
            
            cmd = [
                chrome_path,
                '--headless',
                '--disable-gpu',
                '--print-to-pdf=' + pdf_file,
                '--print-to-pdf-no-header',
                '--no-margins',
                '--page-size=A4',
                '--disable-background-timer-throttling',
                '--disable-backgrounding-occluded-windows',
                '--disable-renderer-backgrounding',
                '--disable-features=TranslateUI',
                '--disable-ipc-flooding-protection',
                '--enable-logging',
                '--log-level=0',
                '--v=1',
                'file://' + html_abs_path
            ]
            
            print(f"Generating professional PDF with Chrome headless...")
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode == 0 and os.path.exists(pdf_file):
                print(f"✅ Successfully created professional PDF: {pdf_file}")
                return True
            else:
                print(f"❌ Chrome headless failed: {result.stderr}")
                return False
                
        except Exception as e:
            print(f"Error with Chrome headless: {e}")
            return False
    
    def convert(self, markdown_file="APP_FLOWCHART.md"):
        """Main conversion method"""
        print("🔄 Professional MultiPurposeApp Flowchart Conversion (Fixed)")
        print("=" * 60)
        
        # Check if markdown file exists
        if not os.path.exists(markdown_file):
            print(f"❌ {markdown_file} not found!")
            return False
        
        # Setup directories
        self.setup_directories()
        
        # Read markdown content
        with open(markdown_file, 'r', encoding='utf-8') as f:
            markdown_content = f.read()
        
        # Extract Mermaid diagrams
        diagrams = self.extract_mermaid_diagrams(markdown_content)
        print(f"Found {len(diagrams)} Mermaid diagrams")
        
        # Generate diagrams with mmdc
        diagram_files = []
        section_names = [
            "Main Application Flow",
            "Authentication Flow",
            "Main Dashboard Navigation", 
            "Lists Management Flow",
            "List Items Management Flow",
            "Deleted Lists Management Flow",
            "Statistics Dashboard Flow",
            "Profile Management Flow",
            "GitHub Sync Flow",
            "iCloud Sync Flow",
            "Error Handling Flow",
            "Data Persistence Flow",
            "Performance Optimization Flow",
            "New User Journey",
            "Returning User Journey",
            "Data Backup Journey"
        ]
        
        print("\n🎨 Generating professional diagrams with Mermaid CLI...")
        for i, diagram in enumerate(diagrams):
            section_name = section_names[i] if i < len(section_names) else f"Diagram {i+1}"
            safe_name = re.sub(r'[^a-zA-Z0-9\s-]', '', section_name).replace(' ', '_').lower()
            diagram_file = self.generate_diagram_with_mmdc(diagram, safe_name, i)
            diagram_files.append(diagram_file)
        
        # Create professional HTML
        print("\n📄 Creating professional HTML document...")
        html_content = self.create_professional_html(markdown_content, diagram_files)
        
        # Save HTML file
        html_file = f"{self.output_dir}/APP_FLOWCHART_PROFESSIONAL.html"
        with open(html_file, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print(f"✅ Created professional HTML: {html_file}")
        
        # Generate PDF
        pdf_file = f"{self.output_dir}/APP_FLOWCHART_PROFESSIONAL.pdf"
        if self.generate_pdf_with_chrome(html_file, pdf_file):
            print(f"\n🎉 Professional conversion complete!")
            print(f"📁 Output directory: {self.output_dir}")
            print(f"📄 HTML file: {html_file}")
            print(f"📄 PDF file: {pdf_file}")
            print(f"🖼️  Diagrams: {self.diagrams_dir}/")
            return True
        else:
            print(f"\n⚠️  PDF generation failed, but HTML is available: {html_file}")
            return False

def main():
    """Main function"""
    converter = ProfessionalFlowchartConverter()
    success = converter.convert()
    
    if success:
        print("\n✅ Professional flowchart conversion successful!")
        print("📋 Next steps:")
        print("1. Open the HTML file in a browser for best viewing")
        print("2. Use browser's Print function (Cmd+P) to save as PDF if needed")
        print("3. Share the PDF file with stakeholders")
    else:
        print("\n❌ Conversion failed. Check the error messages above.")

if __name__ == "__main__":
    main() 