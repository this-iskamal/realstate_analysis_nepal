from flask import Flask, render_template, request, jsonify
from dataanalysis import RealEstateAnalyzer
import os

app = Flask(__name__)

# Initialize analyzer - update path as needed
CSV_PATH = "visualization/realstate_data.csv"
analyzer = RealEstateAnalyzer(CSV_PATH)

@app.route('/')
def index():
    cities = analyzer.get_cities()
    return render_template('index.html', cities=cities)

@app.route('/visualization/<chart_type>')
def visualization(chart_type):
    city = request.args.get('city', None)
    
    if chart_type == 'houses_per_city':
        plot_url = analyzer.houses_per_city()
        title = "Houses Per City"
        
    elif chart_type == 'houses_per_area':
        if not city:
            return "City parameter required", 400
        plot_url = analyzer.houses_per_area_by_city(city)
        title = f"Houses Per Area - {city}"
        
    elif chart_type == 'correlation_heatmap':
        plot_url = analyzer.correlation_heatmap()
        title = "Feature Correlation Heatmap"
        
    elif chart_type == 'price_vs_area':
        plot_url = analyzer.price_vs_area_scatter(city)
        title = f"Price vs Area{' - ' + city if city else ''}"
        
    elif chart_type == 'avg_price_by_city':
        plot_url = analyzer.average_price_by_city()
        title = "Average Price by City"
        
    elif chart_type == 'property_type':
        plot_url = analyzer.property_type_distribution()
        title = "Property Type Distribution"
        
    elif chart_type == 'property_age':
        plot_url = analyzer.property_age_distribution()
        title = "Property Age Distribution"
        
    else:
        return "Invalid chart type", 400
    
    return render_template('visualization.html', 
                         plot_url=plot_url, 
                         title=title,
                         cities=analyzer.get_cities())

@app.route('/api/summary')
def get_summary():
    stats = analyzer.get_summary_stats()
    return jsonify(stats.to_dict())

if __name__ == '__main__':
    app.run(debug=True)
