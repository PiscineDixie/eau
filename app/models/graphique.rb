# coding: utf-8
#
# Cette class represente un graphique.
# Le graphiques est construit avec le API de Google a partir des donnees des
# journees.
# La representation du graphique est donc un URL pour lequel Google retourne
# le graphique.
# Tous les graphiques generes sont des graphiques a barre
#
class Graphique
#  line chart:         cht=lxy
#  datasets:           chd=t:x1,x2|y1,y2
#  scale of data sets: chds=min1, max1, min2, max2
#  color of data sets: chco=c1,c2,c3   FF0000 = red, 00FF00 = green
#  title:              chtt=
#  title decoration:   chts=color,fontsize
#  legend:             chd1=legend1|legend2
#  axis used:          chxt=x,y  
#  axis labels:        chxl=0:|val1|val2|1:|val1|val2
#  range markers:      chm=r,color,start,end

  attr_reader :xyPairs, :minMax, :axisMinMax

  # Creer un graphique pour l'indicateur et la plage de date donnee
  def initialize(indicateur, date1, date2 = nil)
    
    @title = ""
    @subtitle = ""
    @xyPairs = Array.new
    @minMax = Array.new  # for the values [minx, miny, maxx, maxy]
    @axisMinMax = Array.new  # for the axis [minx, miny, maxx, maxy]
    @graphInfo = Array.new # from Mesures
    @minDate = date1 # date du debut
    @maxDate = date2 # date de la fin
    @xLabels = Array.new  # arrays of pairs [text, offset]
    @units='' # units of the measure
    
    # Get the data values to graph. It's an array of [x,y] 2-element arrays
    date2 = date1 - 14 if date2.nil?
    @minDate = date1 > date2 ? date2 : date1
    @maxDate = date1 > date2 ? date1 : date2
    obtainDataValues(indicateur)
    return if @xyPairs.empty?

    # Compute the minmax values
    @minMax = findMinMax
    
    # Retrieve the graph data for this indicateur. It's an array
    @graphInfo = Mesure::IndicateursGraphData.assoc(indicateur)
    throw Exception("Missing graph data for indic: " + indicateur) if @graphInfo.nil?
    
    # The x values are the time of day of the measurements, y as the values

    # Make a title
    @title = indicateur.tr('_', ' ')
    @title << " pour la période du " + @minDate.strftime('%Y-%m-%d') + ' au ' + @maxDate.strftime('%Y-%m-%d')
    
    # The units of measure are take from the graph data
    @units << @graphInfo[1] if not @graphInfo[1].blank?
    
    # Take care of the axix range
    @axisMinMax = @minMax.clone
    if @graphInfo.size == 3
      # We only have a maximum not to exceed. Extend graph to show that
      @axisMinMax[3] = @graphInfo[2] if @graphInfo[2] > @axisMinMax[3]
    elsif @graphInfo.size == 4
      # We have a min and a max. Extend y-axis to include it with a bit or margin
      @axisMinMax[1] = @graphInfo[2] if @graphInfo[2] < @axisMinMax[1]
      @axisMinMax[3] = @graphInfo[3] if @graphInfo[3] > @axisMinMax[3]
    end
    
    # Increase dynamic range by 15%
    @axisMinMax[1] = @axisMinMax[1] - (@axisMinMax[3] - @axisMinMax[1]) * 0.15
    @axisMinMax[3] = @axisMinMax[3] + (@axisMinMax[3] - @axisMinMax[1]) * 0.15
    @axisMinMax[1] = 0 if @axisMinMax[1] < 0
    
    # Axis-x labels. Up to 4 dates
    @xLabels << [@minDate.strftime('%m-%d'), @minDate.to_time.to_i]
    date1 = @minDate + (@maxDate - @minDate).div(3)
    date2 = @minDate + (2 * (@maxDate - @minDate)).div(3)
    @xLabels << [date1.strftime('%m-%d'), date1.to_time.to_i] if date1 > @minDate
    @xLabels << [date2.strftime('%m-%d'), date2.to_time.to_i] if date2 > @minDate
    @xLabels << [@maxDate.strftime('%m-%d'), @maxDate.to_time.to_i] if @maxDate > @minDate
  end

  # Returns an array with [minx, miny, maxx, maxy]
  def findMinMax
    # On the x-axis, we use the min date in seconds, and the day after the max date
    # to account of measures during the last day (e.g., maxDate @ 21:00)
    # For the y-axis, we scan the data to find the high/low values
    res = [@minDate.to_time.to_i, @xyPairs[0][1], (@maxDate+1).to_time.to_i, @xyPairs[0][1]]
    @xyPairs.each do |xy|
      res[1] = xy[1] if res[1] > xy[1]
      res[3] = xy[1] if res[3] < xy[1]
    end
    return res
  end
  
  # Valid si nous avons des data points
  def valid?
    return @xyPairs.length > 0
  end

  
  # Lire les valeurs de la database.
  #  debut et fin sont deux dates
  # retourne une array pour le plot
  def obtainDataValues(indic)
    
    # Retrieve the measures for this date range
    mesures = Mesure.
      joins('as m inner join journees as j on m.journee_id = j.id').
      select('date, temps, valeur').
      where("indicateur = :indic and date >= :minDate and date <= :endDate", 
        {:indic => indic, :minDate => @minDate.to_formatted_s(:db), :endDate => @maxDate.to_formatted_s(:db)})
    
    # If no data, then no valeurs and no graph
    return if mesures.empty?
    
    # Creer la liste des valeurs.
    # 'x' est le temps en seconde, 'y' est la valeur mesuree.
    mesures.each do |m|
      x = m.temps.to_i
      y = m.valeur
      @xyPairs << [x, y]
    end
    @xyPairs.sort! { | x, y | x[0] <=> y[0] }
  end
  
  
  # Generate a graph using the Google API and the state members
  # Args:
  #  size is an array [x, y] dimension
  #  title: when true generate a title
  def toGoogleChart(size = [600, 200], title = false)
    # Start the URL, specify a line chart with x/y values
    url = "http://chart.apis.google.com/chart?cht=lxy"
    
    if (title)
      url << '&chtt=' << @title.tr(' ', '+')
      url << '|' << @subtitle.tr(' ', '+') unless @subtitle.blank?
      url << '&chts=000000,16'   # black, font size
    end
    
    # Put the units of measure as the legend for the plotted line
    unless @units.blank?
      url << '&chdl='+@units
    end
    
    # Set the chart size
    url << '&chs=' + size[0].to_s + 'x' + size[1].to_s
    
    # Type of graph, data sets and their scaling
    url << '&chxt=x,y'
    url << googleDataSets
    url << '&chds='+@axisMinMax[0].to_s+','+@axisMinMax[2].to_s+','+@axisMinMax[1].to_s+','+@axisMinMax[3].to_s
    
    # Range for axis y, positioned labels for axis x
    url << '&chxr=1,'+@axisMinMax[1].to_s+','+@axisMinMax[3].to_s
    url << '&chxl=0:|'
    @xLabels.each { |lp| url << lp[0] << '|' }
    url.chop!
    url << '&chxp=0,'
    @xLabels.each { |lp| url << lp[1].to_s << ',' }
    url.chop!
    url << '|'
    
    # Add the range markers
    url << googleRangeMarkers
    url
  end

  # Return a string that generates range markers in a Google graph
  def googleRangeMarkers
    # The range markers if available
    markers=''
    if @graphInfo.size() == 3
      # Only a maximum is known. Draw as a red line
      dynRange = (@axisMinMax[3] - @axisMinMax[1]).to_f
      y = (@graphInfo[2] - @axisMinMax[1]).to_f/dynRange
      markers << '&chm=r,FF0000,0,' + (y-0.005*dynRange).to_s + ',' + (y+0.005*dynRange).to_s
    elsif @graphInfo.size() == 4
      # A min and max are available. Draw a a light blue range
      lowy = (@graphInfo[2] - @axisMinMax[1]).to_f/(@axisMinMax[3] - @axisMinMax[1]).to_f
      highy = (@graphInfo[3] - @axisMinMax[1]).to_f/(@axisMinMax[3] - @axisMinMax[1]).to_f
      markers << '&chm=r,E5ECF9,0,' + lowy.to_s + ',' + highy.to_s
    end
    markers
  end

  # Convert the array of [x,y] to dataset string used in Google graph
  def googleDataSets
    xs=''
    ys=''
    @xyPairs.each do |xy|
      xs.concat(xy[0].to_s + ',')
      ys.concat(xy[1].to_s + ',')
    end
    '&chd=t:' + xs.chop + '|' + ys.chop
  end

end