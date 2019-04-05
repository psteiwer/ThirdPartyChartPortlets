# ThirdPartyChartPortlets

This project hosts a collection of Portlets for third-party charting libraries. These portlets can be used inside of dashboards as an alternate way of rendering data. Either select a portlet for a charting library you are familiar with or one that has a set of charts you would like to use. Additional, the portlets can be used as examples for implementing other third-party charting libraries.

## Installation
### Installation with Samples
1. Use the Download ZIP option for this project
2. Extract the files and copy path
   * This is the path to the directory that contains README.md and LICENSE
3. Open terminal and ZN to desired namespace
4. Run the following commands:
```
   do $system.OBJ.LoadDir("<PATH FROM STEP 2>","ck",,1)
```
5. From the Management Portal, navigate to DeepSee/Analytics->User Portal
6. Under the "Widgets" section, find the Sample Dashboards.
    * These will be named with "All <third-party name>"
    * This naming convention is based off of the built-in "All Charts" example
  
### Installation without Samples
1. Use the Download ZIP option for this project
2. Extract the files and copy path
   * This is the path to the directory that contains README.md and LICENSE
3. Selectively import portlets of your choice, or all
    * If importing all
    ```
        do $system.OBJ.LoadDir("<PATH FROM STEP 2>\ThirdPartyChartPortlets","ck",,1)
    ```
    * If selectively importing, navigate to the copied path before -> ThirdPartyChartPortlets -> Pick the library of your choice
    ```
        do $system.OBJ.Load("<FULL PATH TO .CLS FILE>","ck")
    ```
