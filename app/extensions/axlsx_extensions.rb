# wonky monkey patching
# taken from Axlsx source version 3.0.1 https://github.com/caxlsx/caxlsx/tree/v3.0.1
# should probably turn this into a PR or something
module Axlsx
  class Chart
    def to_xml_string(str = '')
      str << '<?xml version="1.0" encoding="UTF-8"?>'
      str << ('<c:chartSpace xmlns:c="' << XML_NS_C << '" xmlns:a="' << XML_NS_A << '" xmlns:r="' << XML_NS_R << '">')
      str << ('<c:date1904 val="' << Axlsx::Workbook.date1904.to_s << '"/>')
      str << ('<c:style val="' << style.to_s << '"/>')
      str << ('<c:roundedCorners val="0"/>')
      str << '<c:chart>'
      @title.to_xml_string str
      str << ('<c:autoTitleDeleted val="' << (@title == nil).to_s << '"/>')
      @view_3D.to_xml_string(str) if @view_3D
      str << '<c:floor><c:thickness val="0"/></c:floor>'
      str << '<c:sideWall><c:thickness val="0"/></c:sideWall>'
      str << '<c:backWall><c:thickness val="0"/></c:backWall>'
      str << '<c:plotArea>'
      str << '<c:layout/>'
      yield if block_given?
      str << '</c:plotArea>'
      if @show_legend
        str << '<c:legend>'
        str << ('<c:legendPos val="' << @legend_position.to_s << '"/>')
        str << '<c:layout/>'
        str << '<c:overlay val="0"/>'
        str << '</c:legend>'
      end
      str << '<c:plotVisOnly val="1"/>'
      str << ('<c:dispBlanksAs val="' << display_blanks_as.to_s << '"/>')
      str << '<c:showDLblsOverMax val="1"/>'
      str << '</c:chart>'
      if bg_color
        str << '<c:spPr>'
        str << '<a:solidFill>'
        str << '<a:srgbClr val="' << bg_color << '"/>'
        str << '</a:solidFill>'
        str << '<a:ln>'
        str << '<a:noFill/>'
        str << '</a:ln>'
        str << '</c:spPr>'
      end
      str << '<c:printSettings>'
      str << '<c:headerFooter/>'
      str << '<c:pageMargins b="1.0" l="0.75" r="0.75" t="1.0" header="0.5" footer="0.5"/>'
      str << '<c:pageSetup/>'
      str << '</c:printSettings>'
      str << '</c:chartSpace>'
    end
  end

  class Axis
    def major_gridlines_color=(v)
      @major_gridlines_color = v
    end

    def to_xml_string(str = '')
      str << ('<c:axId val="' << @id.to_s << '"/>')
      @scaling.to_xml_string str
      str << ('<c:delete val="' << @delete.to_s << '"/>')
      str << ('<c:axPos val="' << @ax_pos.to_s << '"/>')
      str << '<c:majorGridlines>'

      str << '<c:spPr>'
      str << '<a:ln>'

      if gridlines == false or @major_gridlines_color.nil?
        str << '<a:noFill/>'
      else
        str << '<a:solidFill>'
        str << ('<a:srgbClr val="' << @major_gridlines_color << '"/>')
        str << '</a:solidFill>'
      end

      str << '</a:ln>'
      str << '</c:spPr>'
      str << '</c:majorGridlines>'

      @title.to_xml_string(str) unless @title == nil
      # Need to set sourceLinked to 0 if we're setting a format code on this row
      # otherwise it will never take, as it will always prefer the 'General' formatting
      # of the cells themselves
      str << ('<c:numFmt formatCode="' << @format_code << '" sourceLinked="' << (@format_code.eql?('General') ? '1' : '0') << '"/>')
      str << '<c:majorTickMark val="none"/>'
      str << '<c:minorTickMark val="none"/>'
      str << ('<c:tickLblPos val="' << @tick_lbl_pos.to_s << '"/>')
      # TODO - this is also being used for series colors
      # time to extract this into a class spPr - Shape Properties
      if @color
        str << '<c:spPr><a:ln><a:solidFill>'
        str << ('<a:srgbClr val="' << @color << '"/>')
        str << '</a:solidFill></a:ln></c:spPr>'
      end
      # some potential value in implementing this in full. Very detailed!
      str << ('<c:txPr><a:bodyPr rot="' << @label_rotation.to_s << '"/><a:lstStyle/><a:p><a:pPr><a:defRPr/></a:pPr><a:endParaRPr/></a:p></c:txPr>')
      str << ('<c:crossAx val="' << @cross_axis.id.to_s << '"/>')
      str << ('<c:crosses val="' << @crosses.to_s << '"/>')
    end
  end
end

# the % sign breaks on macOS for some reason, even though required by spec
# TODO figure out a better way to do this since it prints warning: already initialized constant
Axlsx::BarChart::GAP_AMOUNT_PERCENT = /0*(([0-9])|([1-9][0-9])|([1-4][0-9][0-9])|500)/