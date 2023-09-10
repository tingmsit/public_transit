# Public Transit and Rideshare Services Relationship in Austin Texas
 
**Collaborators**: Jeffrey Finucane, Justin Heinzekehr, Jingya Ye, Ting Sit, Warren Ehrenfried
 
 ### Objective:
 
- The study is to analyze if there is an existing relationship between the number of rideshares versus public transportation services. Do rideshare services serve as a complement to public transportation or cannibalize public transit utilization? What motivates a passenger to switch mode of transportation?

### Clients and Impacts:

- [**CapMetro**](https://capmetro.org/): Public transit provider in Austin, Texas. The company's goal is to develop regional transit system that is accessible to everyone in Austin. The outcome of this study will highlight opportunities for CapMetro to invest capital on fleets of buses investment to improve connectivity of local residents across districts.
- [**The City of Austin**](https://www.austintexas.gov/): To ensure sustainable development of Austin with the expected increase in population. The city has a [50/50/ mode share target](https://data.austintexas.gov/stories/s/M-A-1-Percent-split-of-modes-based-on-commute-to-w/hm3r-8jfy/) by 2039. The outcome of this study is crucial on direct funding to develop public transit infrastructure to increase public transit adoption.
- **Austin Citizens**: By shifting into public transit mode of transportation, the benefits to the citizens are:
    - Lowering greenhouse gas emission by as much as 69%
    - Mitigate traffic congestion with fewer cars on roads, and lead to potential time saving on commuting
    - More affordable mode of transportation which increase community connectivity, particularly for lower income family
    
### Data Source

- [Austin Rideshare Dataset](https://data.world/andytryba/rideaustin)
    - For the ease of access, a copy had been stored on Google Drive[link1](https://drive.google.com/file/d/1So7yjkI9CH5lsOSpNEBhnbv1dQ9Y9wyn/view?usp=sharing)[link2](https://drive.google.com/file/d/1ZBCS-ZanrbCJDVKR1r4uJJP4DwThBwt_/view?usp=sharing)
- [Vechicle Data](https://drive.google.com/file/d/1muf-yYBPGps-2Wtx2v2qN_XtecUi6VgL/view?usp=sharing)
- The rest of the data can be downloaded directly from [Data](https://github.com/tingmsit/public_transit/tree/main/Data) folder within this repository.

### Outline of Approach

1. Exploratory analysis on rideshare - identify potential independent variables which may explain the passenger behaviors using rideshares
2. Distance variable - Euclidean measurement to find average distance of the n-nearest bus stops vs rideshares usage location. This may serve as an important variables for understanding accessibility factor
3. Exploratory analysis on bus ride dataset - similiar to rideshare data, seek to understand if usage pattern could be similar/different from rideshare.
4. Correlation and Significant Tests: check if any independent variables identified from exploratory analysis are significant on explaining potential relationship among public transit and ride share.

### Detail Code Execution
- See [Code Run](https://github.com/tingmsit/public_transit/blob/main/Final%20Code/code_run.Rmd) file


### Findings/Recommendations

By controlling on weekend/weekdays, hour of the day, and location within Austin (divided into 25 grid), significant negative correlation is found among bus service and rideshare services with around **-4%**

Combining with additional data on median income, population density, transportation variety demand, identify 9 census tracts in the north boundary of Austin as opportunities for bus services expansion. Should bus services be expanded to those areas, study indicates **156k** car trips (include rideshares) could be replaced annually, which translate to **98 tons** of carbon reduction.

### Challenges/Next Steps

1. the imprecision of the coordinate data for the rideshare dataset are not sufficient to extract meaningful distances information. Hence distance variable calculated in this study was not a significant factor.
2. Demographic, consumer behavior and preference data are not included, which could be major factors on driving publich transit adoptions.
3. Time series factor of Austin growing population is not captured as data only include 1 year of history.

Obtainin more precise coordinate data, incorporate of consumer behavior data and expand data time horizon become the next steps for this study to improve on the impact estimation.

[Final Report](https://github.com/tingmsit/public_transit/blob/main/Final%20Report/Final%20Project%20Report.pdf)
[Presentation](