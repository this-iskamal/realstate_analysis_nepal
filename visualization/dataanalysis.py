import polars as pl
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
from matplotlib import pyplot as plt
import seaborn as sns
import io
import base64
import os

class RealEstateAnalyzer:
    def __init__(self, csv_path):
        self.csv_path = csv_path
        self.realstate_df = self.load_data()
        
    def load_data(self):
        return pl.read_csv(self.csv_path, schema={
            'Property Id': pl.Int64,
            'Property Name': pl.String,
            'Property Type': pl.String,
            'Bedrooms': pl.Int64,
            'Bathrooms': pl.Int64,
            'Kitchen': pl.Int64,
            'Living Room': pl.Int64,
            'Total Floors': pl.Float64,
            'City': pl.String,
            'Area': pl.String,
            'Property Face': pl.String,
            'Year Built': pl.Int64,
            'Property Age': pl.Int64,
            'Property Area(sqft)': pl.Float64,
            'Price (Rs.)': pl.Int64,
            'Negotiable': pl.Int64,
            'Timestamp': pl.Datetime,
            'Source System': pl.String
        })
    
    def plot_to_base64(self):
        """Convert matplotlib plot to base64 string for web display"""
        img = io.BytesIO()
        plt.savefig(img, format='png', bbox_inches='tight', dpi=100)
        img.seek(0)
        plot_url = base64.b64encode(img.getvalue()).decode()
        plt.close()
        return plot_url
    
    def houses_per_city(self):
        houses_per_city_df = self.realstate_df.get_column("City").value_counts().sort("count", descending=True)
        
        plt.figure(figsize=(12, 6))
        plt.title("Houses Per City Count", fontsize=16)
        sns.barplot(x=houses_per_city_df.get_column("City"), 
                   y=houses_per_city_df.get_column("count"), 
                   palette=sns.color_palette("pastel", 15))
        plt.xlabel("City")
        plt.ylabel("Count")
        plt.xticks(rotation=45)
        plt.tight_layout()
        
        return self.plot_to_base64()
    
    def houses_per_area_by_city(self, city_name):
        houses_city_area = self.realstate_df.filter(
            pl.col("City") == city_name,
        )
        houses_city_area = houses_city_area.get_column("Area").value_counts().sort("count", descending=True)
        
        plt.figure(figsize=(12, 6))
        plt.title(f"{city_name} City Houses Per Area Count", fontsize=16)
        sns.barplot(x=houses_city_area.get_column("Area").head(15), 
                   y=houses_city_area.get_column("count").head(15), 
                   palette=sns.color_palette("pastel"))
        plt.xlabel("Area")
        plt.ylabel("Count")
        plt.xticks(rotation=45)
        plt.tight_layout()
        
        return self.plot_to_base64()
    
    def correlation_heatmap(self):
        heatmap_df = self.realstate_df.select(
            pl.col(["Total Floors", "Bedrooms", "Living Room", "Kitchen", "Bathrooms", "Price (Rs.)"])
        ).corr()
        
        plt.figure(figsize=(10, 8))
        plt.title("Feature Correlation Heatmap", fontsize=16)
        sns.heatmap(heatmap_df, 
                   xticklabels=heatmap_df.columns, 
                   yticklabels=heatmap_df.columns, 
                   annot=True, 
                   cmap="coolwarm")
        plt.tight_layout()
        
        return self.plot_to_base64()
    
    def price_vs_area_scatter(self, city_name=None):
        if city_name:
            scatter_data = self.realstate_df.filter([
                pl.col("Property Area(sqft)").le(5000), 
                pl.col("Total Floors").le(5),
                pl.col("City").eq(city_name)
            ])
            title = f"Price vs Area - {city_name}"
        else:
            scatter_data = self.realstate_df.filter([
                pl.col("Property Area(sqft)").le(5000), 
                pl.col("Total Floors").le(5)
            ])
            title = "Price vs Area - All Cities"
        
        plt.figure(figsize=(12, 6))
        plt.title(title, fontsize=16)
        sns.scatterplot(data=scatter_data, 
                       x="Price (Rs.)", 
                       y="Property Area(sqft)", 
                       hue="Total Floors", 
                       palette="viridis")
        plt.tight_layout()
        
        return self.plot_to_base64()
    
    def average_price_by_city(self):
        avg_city_df = self.realstate_df.select(pl.col("City", "Price (Rs.)")).group_by(pl.col("City")).mean()
        
        plt.figure(figsize=(12, 6))
        plt.title("Average Price per City", fontsize=16)
        sns.barplot(x=avg_city_df.get_column("City"), 
                   y=avg_city_df.get_column("Price (Rs.)"), 
                   palette=sns.color_palette("pastel", 15))
        plt.xlabel("City")
        plt.ylabel("Average Price (Rs.)")
        plt.xticks(rotation=45)
        plt.tight_layout()
        
        return self.plot_to_base64()
    
    def property_type_distribution(self):
        building_df = self.realstate_df.get_column("Property Type").value_counts()
        
        plt.figure(figsize=(10, 6))
        plt.title("Property Type Distribution", fontsize=16)
        sns.barplot(x=building_df.get_column("Property Type"), 
                   y=building_df.get_column("count"), 
                   palette=sns.color_palette("pastel", 15))
        plt.xlabel("Property Type")
        plt.ylabel("Count")
        plt.tight_layout()
        
        return self.plot_to_base64()
    
    def property_age_distribution(self):
        plt.figure(figsize=(12, 6))
        plt.title("Property Age Distribution", fontsize=16)
        sns.histplot(data=self.realstate_df, x="Property Age", bins=30)
        plt.xlabel("Property Age (Years)")
        plt.ylabel("Frequency")
        plt.tight_layout()
        
        return self.plot_to_base64()
    
    def get_cities(self):
        return self.realstate_df.get_column("City").unique().to_list()
    
    def get_summary_stats(self):
        return self.realstate_df.select([
            "Bedrooms", "Living Room", "Kitchen", "Bathrooms", 
            "Total Floors", "Property Area(sqft)", "Price (Rs.)", "Property Age"
        ]).describe()
