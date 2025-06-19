import pandas as pd
import re

def convert_pricing_to_rupees(pricing):
    """Enhanced pricing converter handling all Nepal real estate formats"""
    if pd.isna(pricing) or pricing.strip() == '' or pricing.strip().lower() == 'n/a':
        return None
    
    pricing = pricing.strip()
    pricing_lower = pricing.lower()

    # Handle 'Re 1' special case
    if pricing_lower == 're 1':
        return 1

    # Handle text numbers
    if pricing_lower == 'four crores':
        return 40000000

    # Remove extra words that don't affect value
    pricing_clean = re.sub(r'\b(only|and)\b', '', pricing_lower).strip()
    
    # Handle different format patterns with priority order
    
    # 1. Handle "X cr. Y lakh" (abbreviated format)
    cr_abbr_match = re.search(r'(\d+(?:\.\d+)?)\s*cr\.?\s*(\d+(?:\.\d+)?)\s*lakhs?', pricing_clean)
    if cr_abbr_match:
        crore = float(cr_abbr_match.group(1))
        lakh = float(cr_abbr_match.group(2))
        return crore * 10000000 + lakh * 100000

    # 2. Handle "X Core Y Lakh" (typo for Crore)
    core_match = re.search(r'(\d+(?:\.\d+)?)\s*cores?\s*(\d+(?:\.\d+)?)\s*lakhs?', pricing_clean)
    if core_match:
        crore = float(core_match.group(1))
        lakh = float(core_match.group(2))
        return crore * 10000000 + lakh * 100000

    # 3. Handle concatenated formats "XCroreYLakh" (no spaces)
    concat_match = re.search(r'(\d+(?:\.\d+)?)crores?\s*(\d+(?:\.\d+)?)lakhs?', pricing_clean)
    if concat_match:
        crore = float(concat_match.group(1))
        lakh = float(concat_match.group(2))
        return crore * 10000000 + lakh * 100000

    # 4. Handle "X Crore Y Lakh" with variations (standard format)
    crore_lakh_match = re.search(r'(\d+(?:\.\d+)?)\s*crores?\s*(\d+(?:\.\d+)?)\s*lakhs?', pricing_clean)
    if crore_lakh_match:
        crore = float(crore_lakh_match.group(1))
        lakh = float(crore_lakh_match.group(2)) if crore_lakh_match.group(2) else 0
        return crore * 10000000 + lakh * 100000

    # 5. Handle "X Lakh Y Thousand" format
    lakh_thousand_match = re.search(r'(\d+(?:\.\d+)?)\s*lakhs?\s*(\d+(?:\.\d+)?)\s*thousands?', pricing_clean)
    if lakh_thousand_match:
        lakh = float(lakh_thousand_match.group(1))
        thousand = float(lakh_thousand_match.group(2))
        return lakh * 100000 + thousand * 1000

    # 6. Handle "X Crore Y Thousand" format
    crore_thousand_match = re.search(r'(\d+(?:\.\d+)?)\s*crores?\s*(\d+(?:\.\d+)?)\s*thousands?', pricing_clean)
    if crore_thousand_match:
        crore = float(crore_thousand_match.group(1))
        thousand = float(crore_thousand_match.group(2))
        return crore * 10000000 + thousand * 1000

    # 7. Handle pure "X Crore" format (including CRORE uppercase)
    crore_only_match = re.search(r'(\d+(?:\.\d+)?)\s*crores?$', pricing_clean)
    if crore_only_match:
        crore = float(crore_only_match.group(1))
        return crore * 10000000

    # 8. Handle pure "X Lakh" format (including Lakhs plural)
    lakh_only_match = re.search(r'(\d+(?:\.\d+)?)\s*lakhs?$', pricing_clean)
    if lakh_only_match:
        lakh = float(lakh_only_match.group(1))
        return lakh * 100000

    # 9. Handle special per unit formats (Per Aana, Per Anna, Per Dhur)
    per_unit_match = re.search(r'(\d+(?:\.\d+)?)\s*(?:crores?|lakhs?|thousands?).*per\s*(?:aana|anna|dhur)', pricing_clean)
    if per_unit_match:
        # Extract the base amount and unit
        if 'crore' in pricing_clean:
            crore_per_match = re.search(r'(\d+(?:\.\d+)?)\s*crores?', pricing_clean)
            if crore_per_match:
                return float(crore_per_match.group(1)) * 10000000
        elif 'lakh' in pricing_clean:
            lakh_per_match = re.search(r'(\d+(?:\.\d+)?)\s*lakhs?', pricing_clean)
            if lakh_per_match:
                return float(lakh_per_match.group(1)) * 100000
        elif 'thousand' in pricing_clean:
            thousand_per_match = re.search(r'(\d+(?:\.\d+)?)\s*thousands?', pricing_clean)
            if thousand_per_match:
                return float(thousand_per_match.group(1)) * 1000

    # 10. Handle complex per unit formats like "28 Lakh 50 Thousand Per Aana"
    complex_per_match = re.search(r'(\d+(?:\.\d+)?)\s*lakhs?\s*(\d+(?:\.\d+)?)\s*thousands?.*per\s*(?:aana|anna|dhur)', pricing_clean)
    if complex_per_match:
        lakh = float(complex_per_match.group(1))
        thousand = float(complex_per_match.group(2))
        return lakh * 100000 + thousand * 1000

    # 11. Handle formats with parentheses like "32 Crore (25 lakh per anna)"
    paren_match = re.search(r'(\d+(?:\.\d+)?)\s*crores?\s*\(.*?(\d+(?:\.\d+)?)\s*lakhs?.*per.*\)', pricing_clean)
    if paren_match:
        crore = float(paren_match.group(1))
        return crore * 10000000

    # if no pattern matches, return None
    return None

def is_price_per_unit(pricing):
    """Check if price is per aana/anna/dhur"""
    if pd.isna(pricing):
        return False
    pricing_lower = pricing.lower()
    return any(unit in pricing_lower for unit in ['per aana', 'per anna', 'per dhur'])

def get_pricing_format(pricing):
    """Identify the pricing format for analysis"""
    if pd.isna(pricing):
        return 'Missing'
    
    pricing_lower = pricing.lower()
    
    if 'per aana' in pricing_lower or 'per anna' in pricing_lower:
        return 'Per Aana Format'
    elif 'per dhur' in pricing_lower:
        return 'Per Dhur Format'
    elif 'crore' in pricing_lower and 'lakh' in pricing_lower:
        return 'Crore + Lakh Format'
    elif 'crore' in pricing_lower:
        return 'Crore Only Format'
    elif 'lakh' in pricing_lower:
        return 'Lakh Only Format'
    elif pricing_lower == 're 1':
        return 'Re 1 Format'
    else:
        return 'Other Format'

# transformation script
def transform_pricing_data_enhanced(csv_file_path, output_file_path=None):
    """pricing transformation with detailed analysis"""
    try:
        # load the CSV file
        print(f"Loading data from {csv_file_path}...")
        df = pd.read_csv(csv_file_path)
        
        print(f"Loaded {len(df)} records")
        
        # Apply transformations
        print("Transforming pricing data...")
        df['price_rupees'] = df['Pricing'].apply(convert_pricing_to_rupees)
        df['is_price_per_unit'] = df['Pricing'].apply(is_price_per_unit)
        df['pricing_format'] = df['Pricing'].apply(get_pricing_format)
        
        # Detailed analysis
        print("\n" + "="*60)
        print("DETAILED TRANSFORMATION ANALYSIS")
        print("="*60)
        
        total_records = len(df)
        converted_records = df['price_rupees'].notna().sum()
        per_unit_records = df['is_price_per_unit'].sum()
        
        print(f"Total records: {total_records:,}")
        print(f"Successfully converted: {converted_records:,} ({converted_records/total_records*100:.1f}%)")
        print(f"Per unit prices: {per_unit_records:,} ({per_unit_records/total_records*100:.1f}%)")
        
        # Format breakdown
        print(f"\nPricing Format Breakdown:")
        format_counts = df['pricing_format'].value_counts()
        for format_type, count in format_counts.items():
            print(f"  {format_type}: {count:,} ({count/total_records*100:.1f}%)")
        
        # Show unconverted prices
        unconverted = df[df['price_rupees'].isna() & df['Pricing'].notna()]
        if len(unconverted) > 0:
            print(f"\nUnconverted prices ({len(unconverted)} records):")
            unconverted_samples = unconverted['Pricing'].value_counts().head(10)
            for price, count in unconverted_samples.items():
                print(f"  '{price}': {count} occurrences")
        else:
            print(f"\n✅ ALL PRICING FORMATS SUCCESSFULLY CONVERTED!")
        
        # Price statistics
        if converted_records > 0:
            print(f"\nPrice Statistics (in Rupees):")
            price_stats = df['price_rupees'].describe()
            print(f"  Min: ₹{price_stats['min']:,.0f}")
            print(f"  Max: ₹{price_stats['max']:,.0f}")
            print(f"  Mean: ₹{price_stats['mean']:,.0f}")
            print(f"  Median: ₹{price_stats['50%']:,.0f}")
        
        # Save results
        if output_file_path:
            df.to_csv(output_file_path, index=False)
            print(f"\nTransformed data saved to: {output_file_path}")
        
        return df
        
    except Exception as e:
        print(f"Error: {e}")
        return None

# Usage
if __name__ == "__main__":
    input_file = "data_collection/raw_output/scraped_data1.csv"
    output_file = "data_processing/processed_data/scraped_data1.csv"
    
    result_df = transform_pricing_data_enhanced(input_file, output_file)
