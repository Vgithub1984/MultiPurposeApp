#!/usr/bin/env python3
"""
Alternative PDF Generator for MultiPurposeApp Flowchart
Uses different methods to convert HTML to PDF
"""

import os
import subprocess
import sys

def try_chrome_headless():
    """Try to use Chrome headless to generate PDF"""
    try:
        # Check if Chrome is available
        result = subprocess.run(['which', 'google-chrome'], capture_output=True, text=True)
        if result.returncode == 0:
            chrome_path = result.stdout.strip()
            return generate_pdf_with_chrome(chrome_path)
        
        # Try Chromium
        result = subprocess.run(['which', 'chromium-browser'], capture_output=True, text=True)
        if result.returncode == 0:
            chrome_path = result.stdout.strip()
            return generate_pdf_with_chrome(chrome_path)
        
        # Try on macOS
        result = subprocess.run(['which', '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'], capture_output=True, text=True)
        if result.returncode == 0:
            chrome_path = result.stdout.strip()
            return generate_pdf_with_chrome(chrome_path)
        
        return False
    except Exception as e:
        print(f"Chrome headless failed: {e}")
        return False

def generate_pdf_with_chrome(chrome_path):
    """Generate PDF using Chrome headless"""
    try:
        html_file = "APP_FLOWCHART.html"
        pdf_file = "APP_FLOWCHART.pdf"
        
        # Get absolute path
        html_abs_path = os.path.abspath(html_file)
        
        cmd = [
            chrome_path,
            '--headless',
            '--disable-gpu',
            '--print-to-pdf=' + pdf_file,
            '--print-to-pdf-no-header',
            '--no-margins',
            '--page-size=A4',
            'file://' + html_abs_path
        ]
        
        print(f"Generating PDF with Chrome headless...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0 and os.path.exists(pdf_file):
            print(f"✅ Successfully created PDF: {pdf_file}")
            return True
        else:
            print(f"❌ Chrome headless failed: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"Error with Chrome headless: {e}")
        return False

def try_weasyprint():
    """Try to use WeasyPrint to generate PDF"""
    try:
        import weasyprint
        
        html_file = "APP_FLOWCHART.html"
        pdf_file = "APP_FLOWCHART.pdf"
        
        print("Generating PDF with WeasyPrint...")
        
        # Convert HTML to PDF
        weasyprint.HTML(filename=html_file).write_pdf(pdf_file)
        
        if os.path.exists(pdf_file):
            print(f"✅ Successfully created PDF: {pdf_file}")
            return True
        else:
            print("❌ WeasyPrint failed to create PDF")
            return False
            
    except ImportError:
        print("WeasyPrint not installed. Install with: pip install weasyprint")
        return False
    except Exception as e:
        print(f"Error with WeasyPrint: {e}")
        return False

def try_pdfkit():
    """Try to use pdfkit to generate PDF"""
    try:
        import pdfkit
        
        html_file = "APP_FLOWCHART.html"
        pdf_file = "APP_FLOWCHART.pdf"
        
        print("Generating PDF with pdfkit...")
        
        # Configure options
        options = {
            'page-size': 'A4',
            'margin-top': '20mm',
            'margin-bottom': '20mm',
            'margin-left': '20mm',
            'margin-right': '20mm',
            'encoding': 'UTF-8',
        }
        
        # Convert HTML to PDF
        pdfkit.from_file(html_file, pdf_file, options=options)
        
        if os.path.exists(pdf_file):
            print(f"✅ Successfully created PDF: {pdf_file}")
            return True
        else:
            print("❌ pdfkit failed to create PDF")
            return False
            
    except ImportError:
        print("pdfkit not installed. Install with: pip install pdfkit")
        return False
    except Exception as e:
        print(f"Error with pdfkit: {e}")
        return False

def create_simple_pdf():
    """Create a simple PDF using reportlab as fallback"""
    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import inch
        
        pdf_file = "APP_FLOWCHART_SIMPLE.pdf"
        
        print("Creating simple PDF with reportlab...")
        
        # Create PDF document
        doc = SimpleDocTemplate(pdf_file, pagesize=A4)
        styles = getSampleStyleSheet()
        
        # Create custom styles
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=18,
            spaceAfter=30,
            alignment=1  # Center alignment
        )
        
        heading_style = ParagraphStyle(
            'CustomHeading',
            parent=styles['Heading2'],
            fontSize=14,
            spaceAfter=12,
            spaceBefore=20
        )
        
        # Content
        story = []
        
        # Title
        story.append(Paragraph("MultiPurposeApp - User Flow Chart", title_style))
        story.append(Spacer(1, 20))
        
        # Metadata
        story.append(Paragraph("Last Updated: July 31, 2025", styles['Normal']))
        story.append(Paragraph("Version: 1.0.0 (MVP)", styles['Normal']))
        story.append(Spacer(1, 20))
        
        # Overview
        story.append(Paragraph("Overview", heading_style))
        story.append(Paragraph("This document provides a comprehensive flowchart of all possible user flows in the MultiPurposeApp, from initial launch to all possible user interactions and navigation paths.", styles['Normal']))
        story.append(Spacer(1, 20))
        
        # Sections
        sections = [
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
            "Complete User Journey Examples"
        ]
        
        for section in sections:
            story.append(Paragraph(section, heading_style))
            story.append(Paragraph(f"This section contains detailed flowcharts and diagrams for {section.lower()}. Please refer to the HTML version for visual diagrams.", styles['Normal']))
            story.append(Spacer(1, 12))
        
        # Build PDF
        doc.build(story)
        
        if os.path.exists(pdf_file):
            print(f"✅ Successfully created simple PDF: {pdf_file}")
            print("Note: This is a text-only version. For diagrams, use the HTML file.")
            return True
        else:
            print("❌ Failed to create simple PDF")
            return False
            
    except ImportError:
        print("reportlab not installed. Install with: pip install reportlab")
        return False
    except Exception as e:
        print(f"Error creating simple PDF: {e}")
        return False

def main():
    """Main function to try different PDF generation methods"""
    
    print("🔄 Converting APP_FLOWCHART.md to PDF...")
    print("=" * 50)
    
    # Check if HTML file exists
    if not os.path.exists("APP_FLOWCHART.html"):
        print("❌ APP_FLOWCHART.html not found!")
        print("Please run convert_flowchart_to_pdf.py first")
        return
    
    # Try different methods
    methods = [
        ("Chrome Headless", try_chrome_headless),
        ("WeasyPrint", try_weasyprint),
        ("pdfkit", try_pdfkit),
        ("ReportLab (Simple)", create_simple_pdf)
    ]
    
    success = False
    
    for method_name, method_func in methods:
        print(f"\n🔄 Trying {method_name}...")
        if method_func():
            success = True
            break
        else:
            print(f"❌ {method_name} failed")
    
    if not success:
        print("\n" + "=" * 50)
        print("❌ All PDF generation methods failed!")
        print("\n📋 Alternative options:")
        print("1. Open APP_FLOWCHART.html in a web browser")
        print("2. Use browser's Print function (Cmd+P) to save as PDF")
        print("3. Install wkhtmltopdf: brew install wkhtmltopdf")
        print("4. Install WeasyPrint: pip install weasyprint")
        print("5. Install pdfkit: pip install pdfkit")
        print("\n📁 Files created:")
        print("- APP_FLOWCHART.html (with rendered diagrams)")
        print("- convert_flowchart_to_pdf.py (conversion script)")
        print("- generate_pdf_alternative.py (this script)")
    else:
        print("\n" + "=" * 50)
        print("✅ PDF generation successful!")
        print("\n📁 Files available:")
        print("- APP_FLOWCHART.html (with rendered diagrams)")
        print("- APP_FLOWCHART.pdf (or similar PDF file)")

if __name__ == "__main__":
    main() 