import polars as pl
from matplotlib import pyplot
import seaborn

if __name__ == "__main__":
    print("Starting Elementary Data Analysis")

    # Load data from csv
    # NOTE: CSV File path depends on the system that this program is being run on
    # So, update the absolute path of the CSV File before running this code
    csv_path = "/home/frenzfries/Dev/realstate_analysis_nepal/elementary_data_analysis/realstate_data.csv"

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
    # print(houses_per_city_df)
    
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

    print(realstate_df.schema)

    pyplot.show()
