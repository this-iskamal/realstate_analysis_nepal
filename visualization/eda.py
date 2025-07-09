import polars as pl
from matplotlib import pyplot
import seaborn

if __name__ == "__main__":
    print("Starting Elementary Data Analysis")

    pl.Config.set_tbl_cols(9)

    # Load data from csv
    # NOTE: CSV File path depends on the system that this program is being run on
    # So, update the absolute path of the CSV File before running this code
    csv_path = "visualization\\realstate_data.csv"

    realstate_df = pl.read_csv(csv_path, schema= {
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

    # BarGraph of Houses per City
    houses_per_city_df = realstate_df.get_column("City").value_counts().sort("count", descending=True)
    
    pyplot.figure(figsize=(16,9))
    pyplot.title("Houses Per City Count")
    seaborn.barplot(x= houses_per_city_df.get_column("City"), y=houses_per_city_df.get_column("count"), palette=seaborn.color_palette("pastel", 15))
    pyplot.xlabel("City")
    pyplot.ylabel("Count")

    # filter `kathmandu` city area
    houses_kathmandu_area = realstate_df.filter(
        pl.col("City") == "Kathmandu",
    )
    houses_kathmandu_area = houses_kathmandu_area.get_column("Area").value_counts().sort("count", descending = True)
    pyplot.figure(figsize=(16,9))
    pyplot.title("Kathmandu City Houses Per Area Count")
    seaborn.barplot(x= houses_kathmandu_area.get_column("Area").head(15), y=houses_kathmandu_area.get_column("count").head(15), palette=seaborn.color_palette("pastel"))
    pyplot.xlabel("Area")
    pyplot.ylabel("Count")

    # filter `Lalitpur` city area
    houses_lalitpur_area = realstate_df.filter(
        pl.col("City") == "Lalitpur",
    )
    houses_lalitpur_area = houses_lalitpur_area.get_column("Area").value_counts().sort("count", descending = True)
    pyplot.figure(figsize=(16,9))
    pyplot.title("Lalitpur City Houses Per Area Count")
    seaborn.barplot(x= houses_lalitpur_area.get_column("Area").head(15), y=houses_lalitpur_area.get_column("count").head(15), palette=seaborn.color_palette("pastel"))
    pyplot.xlabel("Area")
    pyplot.ylabel("Count")

    # filter `Bhaktapur` city area
    houses_bhaktapur_area = realstate_df.filter(
        pl.col("City") == "Bhaktapur",
    )
    houses_bhaktapur_area = houses_bhaktapur_area.get_column("Area").value_counts().sort("count", descending = True)
    pyplot.figure(figsize=(16,9))
    pyplot.title("Bhaktapur City Houses Per Area Count")
    seaborn.barplot(x= houses_bhaktapur_area.get_column("Area").head(15), y=houses_bhaktapur_area.get_column("count").head(15), palette=seaborn.color_palette("pastel"))
    pyplot.xlabel("Area")
    pyplot.ylabel("Count")

    # filter `Pokhara` city area
    houses_pokhara_area = realstate_df.filter(
        pl.col("City") == "Pokhara",
    )
    houses_pokhara_area = houses_pokhara_area.get_column("Area").value_counts().sort("count", descending = True)
    pyplot.figure(figsize=(16,9))
    pyplot.title("Pokhara City Houses Per Area Count")
    seaborn.barplot(x= houses_pokhara_area.get_column("Area").head(15), y=houses_pokhara_area.get_column("count").head(15), palette=seaborn.color_palette("pastel"))
    pyplot.xlabel("Area")
    pyplot.ylabel("Count")

    # NOTE: Generate too many data so limit it too top 20 areas
    # # BarGraph of houses per Area
    houses_per_area_df = realstate_df.get_column("Area").value_counts().sort("count", descending=True).head(15)

    pyplot.figure(figsize=(16,9))
    pyplot.title("Houses Per Area Count")
    seaborn.barplot(x= houses_per_area_df.get_column("Area"), y=houses_per_area_df.get_column("count"), palette=seaborn.color_palette("pastel", 15))
    pyplot.xlabel("Area")
    pyplot.ylabel("Count")

    # Correlation Heatmap of Bathrooms, Kitchen, Bedrooms, Living Room, Total Floors, Property Area, Property Price
    heatmap_df = realstate_df.select(
        pl.col( ["Total Floors", "Bedrooms", "Living Room", "Kitchen", "Bathrooms", "Price (Rs.)"])
    ).corr()
    pyplot.figure(figsize=(16,9))
    pyplot.title("Feature Coorelation Heatmap")
    seaborn.heatmap(heatmap_df, xticklabels=heatmap_df.columns, yticklabels=heatmap_df.columns, annot=True, cmap="coolwarm")

    # NOTE: Scatter plot Price vs Area
    scatter = realstate_df.filter( [pl.col("Property Area(sqft)").le(5000), pl.col("Total Floors").le(5)])
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Area")
    seaborn.scatterplot(data=scatter, x="Price (Rs.)", y="Property Area(sqft)", hue="Total Floors", palette="viridis")

    #NOTE: Price vs Area of Kathmandu
    scatter_kathmandu = realstate_df.filter( [pl.col("Property Area(sqft)").le(5000), pl.col("Total Floors").le(5), pl.col("City").eq("Kathmandu")])
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Area of Kathmandu City")
    seaborn.scatterplot(data=scatter_kathmandu, x="Price (Rs.)", y="Property Area(sqft)", hue="Area", palette="viridis")

    #NOTE: Price vs Area of Bhaktapur
    scatter_bhaktapur = realstate_df.filter( [pl.col("Property Area(sqft)").le(5000), pl.col("Total Floors").le(5), pl.col("City").eq("Bhaktapur")])
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Area of Bhaktapur City")
    seaborn.scatterplot(data=scatter_bhaktapur, x="Price (Rs.)", y="Property Area(sqft)", hue="Area", palette="viridis")

    #NOTE: Price vs Area of Lalitpur
    scatter_lalitpur = realstate_df.filter( [pl.col("Property Area(sqft)").le(5000), pl.col("Total Floors").le(5), pl.col("City").eq("Lalitpur")])
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Area of Lalitpur City")
    seaborn.scatterplot(data=scatter_lalitpur, x="Price (Rs.)", y="Property Area(sqft)", hue="Area", palette="viridis")

    #NOTE: Price vs Area of Pokhara
    scatter_pokhara = realstate_df.filter( [pl.col("Property Area(sqft)").le(5000), pl.col("Total Floors").le(5), pl.col("City").eq("Pokhara")])
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Area of Pokhara City")
    seaborn.scatterplot(data=scatter_pokhara, x="Price (Rs.)", y="Property Area(sqft)", hue="Area", palette="viridis")

    #NOTE: Price vs Total Floors
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Total Floors")
    seaborn.scatterplot(data=scatter, x="Price (Rs.)", y="Total Floors", palette="viridis")

    #NOTE: Price vs Total Floors of Kathmandu
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Total Floors of Kathmandu City")
    seaborn.scatterplot(data=scatter_kathmandu, x="Price (Rs.)", y="Total Floors", hue="Area", palette="viridis")

    #NOTE: Price vs Total Floors of Bhaktapur
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Total Floors of Bhaktapur City")
    seaborn.scatterplot(data=scatter_bhaktapur, x="Price (Rs.)", y="Total Floors", hue="Area", palette="viridis")

    #NOTE: Price vs Total Floors of Kathmandu
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Total Floors of Lalitpur City")
    seaborn.scatterplot(data=scatter_lalitpur, x="Price (Rs.)", y="Total Floors", hue="Area", palette="viridis")

    #NOTE: Price vs Total Floors of Kathmandu
    pyplot.figure(figsize=(16,9))
    pyplot.title("Scatter Plot of Price vs Total Floors of Pokhara City")
    seaborn.scatterplot(data=scatter_pokhara, x="Price (Rs.)", y="Total Floors", hue="Area", palette="viridis")

    #NOTE: Summary of numerical data
    print(scatter.select(
        pl.col("Bedrooms", "Living Room", "Kitchen", "Bathrooms", "Total Floors", "Property Area(sqft)", "Price (Rs.)", "Property Age")
    ).describe())

    # Average Price by city
    avg_city_df = realstate_df.select(pl.col("City", "Price (Rs.)")).group_by(pl.col("City")).mean()
    pyplot.figure(figsize=(16,9))
    pyplot.title("Average Price per city")
    seaborn.barplot(x=avg_city_df.get_column("City"), y=avg_city_df.get_column("Price (Rs.)"), palette=seaborn.color_palette("pastel", 15))

    # Average Price by area Top 15
    avg_area_df = realstate_df.select(pl.col("Area", "Price (Rs.)")).group_by(pl.col("Area")).mean().sort(pl.col("Price (Rs.)"), descending=True).head(15)
    pyplot.figure(figsize=(16,9))
    pyplot.title("Average Price per Area")
    seaborn.barplot(x=avg_area_df.get_column("Area"), y=avg_area_df.get_column("Price (Rs.)"), palette=seaborn.color_palette("pastel", 15))

    # Average Price by year
    avg_year_df = realstate_df.select(pl.col("Year Built", "Price (Rs.)")).group_by(pl.col("Year Built")).mean()
    pyplot.figure(figsize=(16,9))
    pyplot.title("Average Price per Year Built")
    seaborn.barplot(x=avg_year_df.get_column("Year Built"), y=avg_year_df.get_column("Price (Rs.)"), palette=seaborn.color_palette("pastel", 15))


    # Ratio of commercial buildings vs civilian buildings
    building_df = realstate_df.get_column("Property Type").value_counts()
    pyplot.figure(figsize=(16,9))
    seaborn.barplot(x=building_df.get_column("Property Type"), y=building_df.get_column("count"), palette=seaborn.color_palette("pastel", 15))
    pyplot.title("Property Type")

    # Property Age Distribution
    pyplot.figure(figsize=(16,9))
    pyplot.title("Property Age Distribution")
    seaborn.histplot(data=realstate_df, x="Property Age")

    # Ratio of property face
    building_face_df = realstate_df.get_column("Property Face").value_counts()
    pyplot.figure(figsize=(16,9))
    pyplot.title(" Property Face Count")
    seaborn.barplot(x=building_face_df.get_column("Property Face"), y=building_face_df.get_column("count"), palette=seaborn.color_palette("pastel", 15))

    # numerical data pair plot for RESIDENTIAL Area
    numerical_df = realstate_df.filter([pl.col("Property Type").eq("RESIDENTIAL"), pl.col("Total Floors").is_between(0,10), pl.col("Property Area(sqft)").is_between(0,5000)])
    numerical_df = numerical_df.select(
        [pl.col("Bedrooms"), pl.col("Living Room"), pl.col("Bathrooms"), pl.col("Kitchen"), pl.col("Total Floors"), pl.col("Property Area(sqft)")]
    )
    seaborn.pairplot(data=numerical_df.to_pandas(), kind="scatter", diag_kind="kde", hue="Total Floors")

    # numerical data pair plot for SEMI-RESIDENTIAL Area
    numerical_df = realstate_df.filter([pl.col("Property Type").eq("SEMI-COMMERCIAL"), pl.col("Total Floors").is_between(0,10), pl.col("Property Area(sqft)").is_between(0,5000)])
    numerical_df = numerical_df.select(
        [pl.col("Bedrooms"), pl.col("Living Room"), pl.col("Bathrooms"), pl.col("Kitchen"), pl.col("Total Floors"), pl.col("Property Area(sqft)")]
    )
    seaborn.pairplot(data=numerical_df.to_pandas(), kind="scatter", diag_kind="kde", hue="Total Floors")

    # numerical data pair plot for COMMERCIAL Area
    numerical_df = realstate_df.filter([pl.col("Property Type").eq("COMMERCIAL"), pl.col("Total Floors").is_between(0,10), pl.col("Property Area(sqft)").is_between(0,5000)])
    numerical_df = numerical_df.select(
        [pl.col("Bedrooms"), pl.col("Living Room"), pl.col("Bathrooms"), pl.col("Kitchen"), pl.col("Total Floors"), pl.col("Property Area(sqft)")]
    )
    seaborn.pairplot(data=numerical_df.to_pandas(), kind="scatter", diag_kind="kde", hue="Total Floors")

    pyplot.show()