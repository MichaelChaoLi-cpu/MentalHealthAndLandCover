# Mental Health and Land Cover: A Global Analysis Based on Random Forests (DP02)  
Nature features and processes in living environments can help to reduce stress and improve mental health. Different land types have disproportionate impacts on mental health. However, the relationships between mental health and land cover are inconclusive. Here, we show the complex relationships between mental health and percentages of eight land types based on the random forest method and Shapley additive explanations. The accuracy of our model is 93.09%, while it is normally no more than 20% in previous studies. According to the analysis results, we estimate the average effects of eight land types. Shrubland, wetland, and bare land have the highest effects on mental health due to their scarcity in living environments. Cropland, forest, and water could improve mental health in the high population-density areas. The impacts of urban land and grassland increases are tiny compared with other land types. Due to scarcity values, the current land cover composition influences people’s attitudes toward a certain land type. This paper provides insights to formulate better land-use policies to improve mental health and eventually to achieve a sustainable society based on a machine learning case study.  
  
## Author  
Chao Li, Shunsuke Managi  

## Result: Monrtary Values of Land Cover (example)  
![](05_Figure/MV_Grid_Bareland.jpg)  
    
## Result: SHAP of Land Cover (example)    
![](05_Figure/SHAP_Bareland.jpg)

## Maunscript  
[**Mental Health and Land Cover: A Global Analysis Based on Random Forests**](06_Manuscript/MentalHealthandLandCover.pdf)  
   
## Python Code
Coming soon!
     
## R Code (Retired)  
**[01_DW_BuildDataset_v1.R](03_RCode/01_DW_BuildDataset_v1.R)**: This script is to wash the data to get the data set in the analysis. All features are reserved.  
**[02_AN_MentalHealthRandomForestTest_v1.R](03_RCode/02_AN_MentalHealthRandomForestTest_v1.R)**: This script is to run random forest with 48 features. Aborted.   
**[03_AN_PartialDependenceProfileImprovement_v1.R](03_RCode/03_AN_PartialDependenceProfileImprovement_v1.R)**: This script is to get PPDF based on the PDP from [04_AN_MentalHealthRf47CutRange_v1.R](03_RCode/04_AN_MentalHealthRf47CutRange_v1.R).   
**[04_AN_MentalHealthRf47CutRange_v1.R](03_RCode/04_AN_MentalHealthRf47CutRange_v1.R)**: This script conducts the analysis based on random forest. 47 feature are used. The model is weighted.    
**[05_AN_MarginalSubstitutionRate1hm_v1.R](03_RCode/05_AN_MarginalSubstitutionRate1hm_v1.R)**: This script calculate the monetory values.      
**[06_VI_Visualization_v1.R](03_RCode/06_VI_Visualization_v1.R)**: This script is to visualize the result in the manuscript.     
**[07_AN_Rf47CutRangeMtrySelection_v1.R](03_RCode/07_AN_Rf47CutRangeMtrySelection_v1.R)**: This script is to try Ntry from 11 to 21.  
    
   
## Workflow

   
## Contact Us:
- Email: Prof. Shunsuke Managi <managi@doc.kyushu-u.ac.jp>  
- Email: Chao Li <chaoli0394@gmail.com>
  
## Term of Use:
Authors/funders retain copyright (where applicable) of code on this Github repo. This GitHub repo and its contents herein, including data, link to data source, and analysis code that are intended solely for reproducing the results in the manuscript "Mental Health and Land Cover: A Global Analysis Based on Random Forests". The analyses rely upon publicly available data from multiple sources, that are often updated without advance notice. We hereby disclaim any and all representations and warranties with respect to the site, including accuracy, fitness for use, and merchantability. By using this site, its content, information, and software you agree to assume all risks associated with your use or transfer of information and/or software. You agree to hold the authors harmless from any claims relating to the use of this site.  
  