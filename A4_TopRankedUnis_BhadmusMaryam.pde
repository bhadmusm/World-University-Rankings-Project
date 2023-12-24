import org.gicentre.geomap.*;


GeoMap geoMap;
Table tabWorldUni;
color minColour, maxColour;
float dataMax;
color buttoncolor;
boolean colorByOverallRank = true; 
boolean colorByTeachingRank = false;
boolean colorByResearchRank = false;
boolean colorByCitationsRank = false;
boolean colorByIncomeRank = false;
boolean colorByOutlookRank = false;
boolean colorByStudentsNumber = false;
int columnNUM = 0;
String selectedCountry = "";  // Variable to store the selected country name
float maxAvgStudents = 0; // Global variable for maximum average students
float maxAvgIntlStudents = 0; // Global variable for maximum average international students
PFont myFont;
PFont myFont2;
PFont myFont3;
String hoveredUniversity = "";
String hoveredUniversityCitationsRank = "";
boolean showUniversityBox = false;


void setup() {
  size(1920, 975);
  geoMap = new GeoMap(0, 100, 1220, 810, this);
  geoMap.readFile("world");
  //geoMap.writeAttributesAsTable(300);

  tabWorldUni = loadTable("TIMES_WUR2024V8.csv", "header");
  stroke(0);
  dataMax = 0;
  for (TableRow row : tabWorldUni.rows()) {
    dataMax = max(dataMax, row.getFloat(0));
  }

  minColour = color(#CDCAF2);
  maxColour = color(#282278);
  
  myFont = createFont("Arial", 16);
  
  myFont3 = createFont("LEMONMILK-Medium.otf", 32);
}



void draw() {
  background(#797b9e);
  strokeWeight(1.2);
  stroke(50);

  // Draw countries and check for mouse hover
  for (int id : geoMap.getFeatures().keySet()) {
    String countryName = geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME");

    // Find the lowest rank for the current country
    float lowestRank = getLowestRank(tabWorldUni, countryName, columnNUM);

    if (lowestRank > 0) {
      float colRank = pow(1 - lowestRank / dataMax, 5);
      fill(lerpColor(minColour, maxColour, colRank));
    } else {
      fill(250); // Default color if no matching data is available
    }
    geoMap.draw(id); // Draw country

    if (geoMap.getID(mouseX, mouseY) == id) {
      selectedCountry = countryName;  // Store the selected country name
    }
  }

  // Draw the country at the mouse position in a different color
  int mouseID = geoMap.getID(mouseX, mouseY);
  if (mouseID != -1) {
    fill(#131043); // dark purple
    geoMap.draw(mouseID);
  }

  // Draw other elements
  Countrygraphsrect(); // Graphs background
  worldLegendrect();   // Legend
  drawTitle("2024 World University Rankings"); // Title

  // Check if the mouse is over a country and display info
  for (int id : geoMap.getFeatures().keySet()) {
    String countryName = geoMap.getAttributeTable().findRow(str(id), 0).getString("NAME");
    float lowestRank = getLowestRank(tabWorldUni, countryName, columnNUM);
    if (geoMap.getID(mouseX, mouseY) == id) {
      displayInfo(countryName, lowestRank);
      break; // Break out of the loop after finding the hovered country
    }
  }

fill(255);
strokeWeight(1.2);
rect(0,911,1220,63);

int buttonWidth = 110;
int buttonHeight = 40;
int buttonSpacing = 50;

drawButton("Overall Rank", 10, height - 50, buttonWidth, buttonHeight, colorByOverallRank, buttoncolor);
drawButton("Teaching Rank", 10 + buttonWidth + buttonSpacing, height - 50, buttonWidth, buttonHeight, colorByTeachingRank, buttoncolor);
drawButton("Research Rank", 10 + (buttonWidth + buttonSpacing) * 2, height - 50, buttonWidth, buttonHeight, colorByResearchRank, buttoncolor);
drawButton("Citations Rank", -5+ (buttonWidth + buttonSpacing) * 3, height - 50, buttonWidth, buttonHeight, colorByCitationsRank, buttoncolor);
drawButton("Industry Income Rank", -5 + (buttonWidth + buttonSpacing) * 4, height - 50, buttonWidth+30, buttonHeight, colorByIncomeRank, buttoncolor);
drawButton("International Outlook Rank", 10 + (buttonWidth + buttonSpacing) * 5, height - 50, buttonWidth+65, buttonHeight, colorByOutlookRank, buttoncolor);
drawButton("Student Population Rank", 10 + ((buttonWidth + buttonSpacing) * 6)+50, height - 50, buttonWidth+50, buttonHeight, colorByStudentsNumber, buttoncolor);
}


void drawButton(String label, float x, float y, float w, float h, boolean active, color buttoncolor) {
  buttoncolor = minColour;
  stroke(0);
  strokeWeight(2);
  fill(active ? color(buttoncolor) : color(150));
  rect(x, y, w, h);

  fill(0);
  strokeWeight(2);
  stroke(0);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(label, x + w / 2, y + h / 2);
}



ArrayList<TableRow> getHighestRankedUniversities(Table table, String countryName) {
  ArrayList<TableRow> highestRankedUnis = new ArrayList<TableRow>();
  for (TableRow row : table.matchRows(countryName, "location")) {
    highestRankedUnis.add(row);
  }
  
  // Sort universities by rank in descending order (higher rank number is lower)
  //highestRankedUnis.sort((a, b) -> Float.compare(b.getFloat("rank"), a.getFloat("rank")));
  return new ArrayList<TableRow>(highestRankedUnis.subList(0, min(3, highestRankedUnis.size())));
}

void Countrygraphsrect() {
  fill(255);
  stroke(0);
  strokeWeight(2);
  float rectWidth = 690;
  float rectHeight = height - 80;
  float rectX = 1225;
  float rectY = height / 2 - rectHeight / 2;
  rect(1220, 0, 705, 975);
  noStroke();
  rect(rectX, rectY, rectWidth, rectHeight);
 
  stroke(0);
  fill(#9872dc,127);
  rect(1400, 5, 360, 60);
  fill(255);
  noStroke();
  rect(1410, 13, 340, 45);
  
  fill(0);
  textAlign(CENTER, TOP);
  textSize(40);
  text(selectedCountry, rectX + rectWidth / 2, rectY -25);  // Display selected country name
  
    // Display the total number of universities in the ranking for the selected country
    int uniCount = countUniversitiesInRanking(tabWorldUni, selectedCountry);
    textSize(18);
    text("Total Universities in Ranking", rectX + 350, rectY + 60);
    textSize(30); 
    text(str(uniCount), rectX + 350, rectY + 90); 
 
  /*textAlign(LEFT, TOP);
  textSize(18);
  text("Top 3 Universities and their Overall Ranks", 1240, 70);  // Display title for university list

  // Get and display the three highest-ranked universities
  ArrayList<TableRow> highestRankedUnis = getHighestRankedUniversities(tabWorldUni, selectedCountry);
  textSize(16);
  textAlign(LEFT, TOP);
  for (int i = 0; i < highestRankedUnis.size(); i++) {
    TableRow uni = highestRankedUnis.get(i);
    text((i + 1) + ". " + uni.getString("name") + "   Rank: " + uni.getString("rank"), rectX + 20, rectY + 60 + i * 30);
  } */
  
  // Call the scatterplot function
  drawScatterPlot(1280, rectY + 190, selectedCountry);
  textSize(18);
  fill(0);
  text("Teaching vs Research", 1520, 210);  // Display title for university list

  // Call the scatterplot function
  drawScatterPlot2(1610, rectY + 190, selectedCountry);
  textSize(18);
  fill(0);
  text("Income vs Outlook", 1825, 200); 
  
  // Call the new function to draw the hovered university box
  drawHoveredUniversityBox();
  
   // Call the student-staff ratio bar chart function
  drawStudentStaffRatioBarChart(1280, rectY + 590, selectedCountry);
  textSize(18);
  fill(0);
  text("Average Student-Staff Ratio", 1430, 600);  

  // bar chart for average students and international students
    drawAverageStudentsBarChart(1710, rectY + 810, selectedCountry); 
    textSize(18);
    fill(0);
    text("Average Student Numbers", 1800, 770);  
    
  // pie chart for gender ratio
    drawGenderRatioPieChart(rectX + rectWidth -80, rectY + rectHeight - 265, selectedCountry);
    textSize(18);
    fill(0);
    text("Average Female-Male Ratio", 1780, 600);  


    // Draw the pie chart for university types
    drawUniversityTypePieChart(rectX+300 , rectY+910, selectedCountry);
    textSize(18);
    fill(0);
    text("University Record Types", 1450, 805);  

    
}


void worldLegendrect() {
  fill(255);
  strokeWeight(2);
  stroke(0);
  float legWidth = 150;
  float legHeight = 300;
  float legX = 50;
  float legY = 450;
  rect(legX, legY, legWidth, legHeight);

  fill(0);
  textAlign(CENTER, TOP);
  textSize(20);
  String legendText = "Legend";
  text(legendText, legX + legWidth / 2, legY + 10);
  
  fill(0);
  rect(73, 498, 33, 223);
  
  noStroke();

  color topColor = maxColour;
  color bottomColor = minColour;

  int numSteps = 220;

  for (int i = 0; i < numSteps; i++) {
    float inter = map(i, 0, numSteps, 0.0, 1.0);
    color c = lerpColor(topColor, bottomColor, inter);
    fill(c);
    rect(75, 500 + i, 30, 1);
  }

  fill(0);
  textSize(14);
  text("1", 150, 495);
  text("50", 150, 530);
  text("100", 150, 560);
  text("500", 150, 595);
  text("1000", 150, 630);
  text("1500", 150, 670);
  text("2000+", 150, 705);

  text("Rank", 125, 727);
}

void drawTitle(String title) {
  fill(255);
  stroke(0);
  strokeWeight(7);
  float titleWidth = textWidth(title) + 570;
  float titleHeight = 70;
  float titleX = 260;
  float titleY = 10;
  

  rect(titleX, titleY, titleWidth, titleHeight);
  noFill();
  strokeWeight(12);
  stroke(107, 56, 199, 127); 
  rect(titleX, titleY, titleWidth, titleHeight);

  textFont(myFont3);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(40);
  text(title, 645, (titleY + titleHeight / 2) -5);
  textFont(myFont);
  
}

float getLowestRank(Table table, String countryName, int columnNUM) {
  float lowestRank = Float.MAX_VALUE;

  for (TableRow row : table.rows()) {
    String currentCountry = row.getString("location");
    if (currentCountry.equals(countryName)) {
      float currentRank = row.getFloat(columnNUM);
      if (currentRank < lowestRank) {
        lowestRank = currentRank;
      }
    }
  }

  if (lowestRank == Float.MAX_VALUE) {
    return -1;
  } else {
    return lowestRank;
  }
}


void displayInfo(String countryName, float rank) {
  int universityNameCol = 1;
  int teachingRankCol = 5;
  int researchRankCol = 7;
  int citationsRankCol = 9;
  int industryIncomeRankCol = 11;
  int intlOutlookRankCol = 13;
  int numStudentsCol = 19;
  //int recordTypeCol = 14;

  fill(255);
  stroke(0);
  strokeWeight(1.2);
  rect(mouseX + 10, mouseY - 50, 400, 200);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Country: " + countryName, mouseX + 20, mouseY - 40);
  text("Highest University Rank: " + (rank == -1 ? "N/A" : str(rank)), mouseX + 20, mouseY - 20);

  // Display additional information
  TableRow row = getUniversityData(tabWorldUni, countryName);
  if (row != null) {
    text("University Name: " + row.getString(universityNameCol), mouseX + 20, mouseY + 10);
    text("Teaching Rank: " + row.getString(teachingRankCol), mouseX + 20, mouseY + 30);
    text("Research Rank: " + row.getString(researchRankCol), mouseX + 20, mouseY + 50);
    text("Citations Rank: " + row.getString(citationsRankCol), mouseX + 20, mouseY + 70);
    text("Industry Income Rank: " + row.getString(industryIncomeRankCol), mouseX + 20, mouseY + 90);
    text("Intl Outlook Rank: " + row.getString(intlOutlookRankCol), mouseX + 20, mouseY + 110);
    text("Number of Students: " + row.getString(numStudentsCol), mouseX + 20, mouseY + 130);
    //text("Record Type: " + row.getString(recordTypeCol), mouseX + 20, mouseY + 150);
  }
}

TableRow getUniversityData(Table table, String countryName) {
  for (TableRow row : table.rows()) {
    String currentCountry = row.getString("location");
    if (currentCountry.equals(countryName)) {
      return row;
    }
  }
  return null;
}


// function to draw the scatter plot
void drawScatterPlot(float x, float y, String country) {
  
  showUniversityBox = false;
  
  fill(255);
  rect(x, y, 300, 300);

  // Draw X and Y axis
  stroke(0);
  line(x, y + 300, x + 300, y + 300); // X-axis
  line(x, y, x, y + 300);             // Y-axis

  // Draw X-axis label
  fill(0);
  textAlign(CENTER, TOP);
  textSize(14);
  text("Teaching Rank", x + 150, y + 320);

  // Draw Y-axis label
  textAlign(CENTER, BOTTOM);
  pushMatrix();
  translate(x-40, y + 150);
  rotate(-HALF_PI);
  textSize(14);
  text("Research Rank", 0, 0);
  popMatrix();

  // Draw tick marks and axis values
  textAlign(RIGHT, TOP);
  for (int i = 0; i <= 2673; i += 500) {
    float tickX = map(i, 1, 2673, x, x + 300);
    line(tickX, y + 300, tickX, y + 300 + 5); // X-axis tick marks
    text(String.valueOf(i), tickX, y + 305); // X-axis values
  }

  textAlign(RIGHT, CENTER);
  for (int i = 0; i <= 2673; i += 500) {
    float tickY = map(i, 1, 2673, y + 300, y);
    line(x - 5, tickY, x, tickY); // Y-axis tick marks
    text(String.valueOf(i), x - 8, tickY); // Y-axis values
  }


  // Extract and plot universities data
  for (TableRow uniRow : tabWorldUni.matchRows(country, "location")) {
    float teachingRank = uniRow.getFloat("scores_teaching_rank");
    float researchRank = uniRow.getFloat("scores_research_rank");
    float citationsRank = uniRow.getFloat("scores_citations_rank");

    // Map the ranks to the scatter plot dimensions
    float xPos = map(teachingRank, 1, 2673, x, x + 300);
    float yPos = map(researchRank, 1, 2673, y + 300, y);

    // Determine point size based on citation rank
    float pointSize = map(citationsRank, 1, 2673, 4, 30);

    // Draw the point
    fill(#Ff6464); // Red color
    strokeWeight(1.2);
    ellipse(xPos, yPos, pointSize, pointSize);
    
    if (dist(xPos, yPos, mouseX, mouseY) < pointSize / 2) {
      showUniversityBox = true;
      hoveredUniversity = uniRow.getString("name");
      hoveredUniversityCitationsRank = uniRow.getString("scores_citations_rank");
    }
    
  }
}


void drawScatterPlot2(float x, float y, String country) {
  
  //showUniversityBox = false;
  
  fill(255);
  noStroke();
  rect(x, y, 300, 300);

  // Draw X and Y axis
  stroke(0);
  strokeWeight(2);
  line(x, y + 300, x + 300, y + 300); // X-axis
  line(x, y, x, y + 300);             // Y-axis

  // Draw X-axis label
  fill(0);
  textAlign(CENTER, TOP);
  textSize(14);
  text("Income Rank", x + 150, y + 320);

  // Draw Y-axis label
  textAlign(CENTER, BOTTOM);
  pushMatrix();
  translate(x-2, y + 150);
  rotate(-HALF_PI);
  textSize(14);
  text("Outlook Rank", 0, 0);
  popMatrix();

  // Draw tick marks and axis values
  textAlign(RIGHT, TOP);
  for (int i = 0; i <= 2673; i += 500) {
    float tickX = map(i, 1, 2673, x, x + 300);
    line(tickX, y + 300, tickX, y + 300 + 5); // X-axis tick marks
    text(String.valueOf(i), tickX, y + 305); // X-axis values
  }

  


  // Extract and plot universities data
  for (TableRow uniRow : tabWorldUni.matchRows(country, "location")) {
    float incomeRank = uniRow.getFloat("scores_industry_income_rank");
    float outlookRank = uniRow.getFloat("scores_international_outlook_rank");

    // Map the ranks to the scatter plot dimensions
    float xPos = map(incomeRank, 1, 2673, x, x + 300);
    float yPos = map(outlookRank, 1, 2673, y + 300, y);

    // Draw the point
    fill(#Abf76d); // color
    strokeWeight(1.2);
    ellipse(xPos, yPos, 6, 6);
    
    if (dist(xPos, yPos, mouseX, mouseY) < 3) {
      showUniversityBox = true;
      hoveredUniversity = uniRow.getString("name");
      hoveredUniversityCitationsRank = uniRow.getString("scores_citations_rank");
    }
    
  }
}

void drawHoveredUniversityBox() {
  if (showUniversityBox) {
    fill(255,180);
    noStroke();
    strokeWeight(1.2);
    rect(mouseX + 10, mouseY - 50, 250, 50);

    fill(0);
    textAlign(LEFT, TOP);
    textSize(16);
    text(hoveredUniversity, mouseX + 20, mouseY - 40);
    text("Citations Rank: " + hoveredUniversityCitationsRank, mouseX + 20, mouseY - 20); // Display citations rank
    
  }
}

void drawStudentStaffRatioBarChart(float x, float y, String country) {
  stroke(0);
  strokeWeight(1.5);
  // Set up the bar chart area
  fill(255);
  rect(x, y, 300, 100);

  // Draw X and Y axis
  stroke(0);
  line(x, y + 100, x + 300, y + 100); // X-axis
  line(x, y, x, y + 100);             // Y-axis



  // Calculate the average student-staff ratio for the selected country
  float averageRatio = calculateAverageRatio(tabWorldUni, country);

  // Calculate the lengths of the pink and blue bars based on the given ratios
  float staffBarWidth = map(1 / (1 + averageRatio), 0, 1, 0, 300);
  float studentBarWidth = map(averageRatio / (1 + averageRatio), 0, 1, 0, 300);

  // Draw the pink bar (staff ratio)
  fill(#996df7);
  rect(x, y + 10, staffBarWidth, 50);

  // Draw the blue bar (student ratio)
  fill(#533989);
  rect(x + staffBarWidth, y + 10, studentBarWidth, 50);

  // Display the average ratio value on the bar chart
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(20);
  text(String.format("%.2f", averageRatio), 1422 /*x + staffBarWidth + studentBarWidth / 2*/, y + 31);

  fill(0);
  textSize(16);
  text("Staff", 1355, y + 77);
  fill(#996df7);
  rect(1310,y+70, 20, 20);
  
  fill(0);
  text("Student", 1465, y + 77);
  fill(#533989);
  rect(1410,y+70, 20, 20);
}


float calculateAverageRatio(Table table, String countryName) {
  float totalRatio = 0;
  int count = 0;

  for (TableRow row : table.matchRows(countryName, "location")) {
    float ratio = row.getFloat("stats_student_staff_ratio");
    totalRatio += ratio;
    count++;
  }

  if (count > 0) {
    return totalRatio / count;
  } else {
    return 0;
  }
}

float calculateAverageStudents(Table table, String countryName) {
    float totalStudents = 0;
    int count = 0;

    for (TableRow row : table.matchRows(countryName, "location")) {
        float students = row.getFloat("stu_val");
        totalStudents += students;
        count++;
    }

    if (count > 0) {
        float average = totalStudents / count;
        if (average > maxAvgStudents) {
            maxAvgStudents = average; // Update global variable
        }
        return average;
    } else {
        return 0;
    }
}

float calculateAverageInternationalStudents(Table table, String countryName) {
    float totalIntlStudents = 0;
    int count = 0;

    for (TableRow row : table.matchRows(countryName, "location")) {
        float intlStudents = row.getFloat("intl_val");
        totalIntlStudents += intlStudents;
        count++;
    }

    if (count > 0) {
        float average = totalIntlStudents / count;
        if (average > maxAvgIntlStudents) {
            maxAvgIntlStudents = average; // Update global variable
        }
        return average;
    } else {
        return 0;
    }
}


void drawAverageStudentsBarChart(float x, float y, String country) {
    float avgStudents = calculateAverageStudents(tabWorldUni, country);
    float avgIntlStudents = calculateAverageInternationalStudents(tabWorldUni, country);

    // Assuming max possible averages, adjust as needed
    float maxAvgStudents = 18358; // example maximum
    float maxAvgIntlStudents = 1545; // example maximum

    // Set up the bar chart area
    fill(255);
    rect(x, y - 80, 180, 180);

    // Draw X and Y axis
    stroke(0);
    line(x, y + 100, x + 180, y + 100); // X-axis
    line(x, y, x, y + 100);             // Y-axis

    // Calculate bar heights using map function
    float avgStudentsHeight = map(avgStudents, 0, maxAvgStudents, 0, 60);
    float avgIntlStudentsHeight = map(avgIntlStudents, 0, maxAvgIntlStudents, 0, 5);

    // Draw bars
    float barWidth = 40;
    fill(100, 100, 255); // Color for avgStudents bar
    rect(x + 25, y + 100 - avgStudentsHeight, barWidth, avgStudentsHeight);

    fill(#85e9fd); // Color for avgIntlStudents bar
    rect(x + 110, y + 100 - avgIntlStudentsHeight, barWidth, avgIntlStudentsHeight);

    // Add labels for bar names
    fill(0);
    textSize(14);
    text("National", x + 45, y + 105);
    text("International", x + 135, y + 105);

    // Print average values above or on the bars
    textAlign(CENTER, BOTTOM);
    text(nf(avgStudents, 0, 2), x + 25 + barWidth / 2, y + 100 - avgStudentsHeight - 5); // nf() formats the number
    text(nf(avgIntlStudents, 0, 2), x + 110 + barWidth / 2, y + 100 - avgIntlStudentsHeight - 5);
}

int countUniversitiesInRanking(Table table, String countryName) {
    int count = 0;
    for (TableRow row : table.matchRows(countryName, "location")) {
        // Increment count for each university found in the given country
        count++;
    }
    return count;
}

void drawGenderRatioPieChart(float x, float y, String country) {
    float totalFemale = 0;
    int count = 0;

    for (TableRow row : tabWorldUni.matchRows(country, "location")) {
        float female = row.getFloat("female");
        totalFemale += female;
        count++;
    }

    if (count > 0) {
        float avgFemale = totalFemale / count;
        float avgMale = 100 - avgFemale;

        // Draw the pie chart
        noStroke();

        fill(0);
        arc(x, y, 124, 124, 0, TWO_PI);

        fill(#78acf7);  // Color for male
        arc(x, y, 120, 120, 0, TWO_PI * avgMale);

        fill(#Ffa3c9);  // Color for female
        arc(x, y, 120, 120, TWO_PI * avgFemale / 100, TWO_PI);

        // Display the male and female ratios
        fill(0);
        
        text(nf(avgMale, 0, 2) + "%",1860 , y-15);
        text(nf(avgFemale, 0, 2) + "%",1855 , y+30 );
    }

    stroke(0);
    fill(0);
    text("Female", 1720, y - 10);
    fill(#Ffa3c9);
    rect(1665, y - 30, 20, 20);

    fill(0);
    text("Male", 1715, y + 30);
    fill(#78acf7);
    rect(1665, y + 10, 20, 20);
}



void drawUniversityTypePieChart(float x, float y, String country) {
    int publicCount = 0;
    int privateCount = 0;
    int masterCount = 0;

    for (TableRow row : tabWorldUni.matchRows(country, "location")) {
        String type = row.getString("record_type");
        if (type.equals("public")) {
            publicCount++;
        } else if (type.equals("private")) {
            privateCount++;
        } else if (type.equals("master_account")) {
            masterCount++;
        }
    }

    // Calculate the total count and the angles for the pie chart
    int totalCount = publicCount + privateCount + masterCount;
    float publicAngle = PI * publicCount / totalCount;
    float privateAngle = PI * privateCount / totalCount;
    float masterAngle = PI - publicAngle - privateAngle; // Rest of the half-circle
    
    fill(50);
    arc(1525, 951, 257, 257, PI, TWO_PI, PIE);
    
    // Draw the pie chart
    noStroke();
    if (totalCount > 0) {
        // Master account segment
        fill(#9149c7); // Color for master account universities
        arc(x, y, 250, 250, -PI, -PI + masterAngle, PIE);

        // Private segment
        fill(#Fb73df); // Color for private universities
        arc(x, y, 250, 250, -PI + masterAngle, -PI + masterAngle + privateAngle, PIE);

        // Public segment
        fill(100, 100, 255); // Color for public universities
        arc(x, y, 250, 250, -PI + masterAngle + privateAngle, -PI + masterAngle + privateAngle + publicAngle, PIE);
    }
    
  fill(255); // Set fill color to white
  noStroke(); // No outline

  float radius = 70;
  float startAngle = PI; // Start angle for semi-circle
  float endAngle = TWO_PI; // End angle for semi-circle
 
  // Draw the semi-circle
  fill(50);
  arc(1525, 950, 72 * 2, 72 * 2, startAngle, endAngle, PIE);
  fill(255);
  arc(1525, 954, (radius-2) * 2, (radius+2) * 2, startAngle, endAngle, PIE);
  
  stroke(0);  
  fill(0);
  text("Master Account", 1335, y -70);
  fill(#9149c7);
  rect(1240,y-90, 20, 20);
  
  fill(0);
  text("Private", 1335, y -40);
  fill(#Fb73df);
  rect(1240,y-60, 20, 20);
  
  fill(0);
  text("Public", 1335, y -10);
  fill(100, 100, 255);
  rect(1240,y-30, 20, 20);
  
  


}

void mousePressed() {
  int buttonWidth = 110;
  int buttonSpacing = 60;
  
  if (mouseX > 10 && mouseX < 120 && mouseY > height - 50 && mouseY < height - 20) {
    colorByOverallRank = true;
    colorByTeachingRank = false;
    colorByResearchRank = false;
    colorByCitationsRank = false;
    colorByIncomeRank = false;
    colorByOutlookRank = false;
    colorByStudentsNumber = false;
    
    minColour = color(#CDCAF2);
    maxColour = color(#282278);
    columnNUM = 0;
    redraw();
  } else if (mouseX > 10 + buttonWidth + buttonSpacing && mouseX < 10 + buttonWidth * 2 + buttonSpacing && mouseY > height - 50 && mouseY < height - 20) {
    colorByOverallRank = false;
    colorByTeachingRank = true;
    colorByResearchRank = false;
    colorByCitationsRank = false;
    colorByIncomeRank = false;
    colorByOutlookRank = false;
    colorByStudentsNumber = false;
    
    //minColour = color(#CBE1A6); //green
    //maxColour = color(#344B0F);
    minColour = color(#CDCAF2);
    maxColour = color(#282278);
    columnNUM = 5;
    redraw();
  } else if (mouseX > 10 + (buttonWidth + buttonSpacing) * 2 && mouseX < 10 + (buttonWidth + buttonSpacing) * 3 && mouseY > height - 50 && mouseY < height - 20) {
    colorByOverallRank = false;
    colorByTeachingRank = false;
    colorByResearchRank = true;
    colorByCitationsRank = false;
    colorByIncomeRank = false;
    colorByOutlookRank = false;
    colorByStudentsNumber = false;
    
    minColour = color(#CDCAF2);
    maxColour = color(#282278);
    columnNUM = 7;
    redraw();
  } else if (mouseX > -5 + (buttonWidth + buttonSpacing) * 3 && mouseX < -5 + (buttonWidth + buttonSpacing) * 4 && mouseY > height - 50 && mouseY < height - 20) {
    colorByOverallRank = false;
    colorByTeachingRank = false;
    colorByResearchRank = false;
    colorByCitationsRank = true;
    colorByIncomeRank = false;
    colorByOutlookRank = false;
    colorByStudentsNumber = false;
    
    minColour = color(#CDCAF2);
    maxColour = color(#282278);
    columnNUM = 9;
    redraw();
  } else if (mouseX > -5 + (buttonWidth + buttonSpacing) * 4 && mouseX < -5 + (buttonWidth + buttonSpacing) * 5 && mouseY > height - 50 && mouseY < height - 20) {
    colorByOverallRank = false;
    colorByTeachingRank = false;
    colorByResearchRank = false;
    colorByCitationsRank = false;
    colorByIncomeRank = true;
    colorByOutlookRank = false;
    colorByStudentsNumber = false;
    
    minColour = color(#CDCAF2);
    maxColour = color(#282278);
    columnNUM = 11;
    redraw();
  } else if (mouseX > 10 + (buttonWidth + buttonSpacing) * 5 && mouseX < 10 + (buttonWidth + buttonSpacing) * 6 && mouseY > height - 50 && mouseY < height - 20) {
    colorByOverallRank = false;
    colorByTeachingRank = false;
    colorByResearchRank = false;
    colorByCitationsRank = false;
    colorByIncomeRank = false;
    colorByOutlookRank = true;
    colorByStudentsNumber = false;
    
    minColour = color(#CDCAF2);
    maxColour = color(#282278);
    columnNUM = 13;
    redraw();
  } else if (mouseX > 10 + ((buttonWidth + buttonSpacing) * 6) + 50 && mouseX < 10 + ((buttonWidth + buttonSpacing) * 7) + 70 && mouseY > height - 50 && mouseY < height - 20) {
    colorByOverallRank = false;
    colorByTeachingRank = false;
    colorByResearchRank = false;
    colorByCitationsRank = false;
    colorByIncomeRank = false;
    colorByOutlookRank = false;
    colorByStudentsNumber = true;
    
    minColour = color(#CDCAF2);
    maxColour = color(#282278);
    columnNUM = 36;
    redraw();
  }
}




void mouseMoved() {
  redraw();
}
