xquery version "3.0";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace c="http://schemas.openxmlformats.org/drawingml/2006/chart";
declare namespace a="http://schemas.openxmlformats.org/drawingml/2006/main";
declare namespace b="http://schemas.openxmlformats.org/spreadsheetml/2006/main";
declare namespace r="http://schemas.openxmlformats.org/officeDocument/2006/relationships";
declare namespace cdr="http://schemas.openxmlformats.org/drawingml/2006/chartDrawing";
declare namespace xdr="http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing";
declare namespace rels="http://schemas.openxmlformats.org/package/2006/relationships";

declare default element namespace "http://www.w3.org/2000/svg";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization"; 
declare option output:method "xml"; 
declare option output:indent "yes"; 
declare option output:omit-xml-declaration "no";
declare option output:encoding "UTF-8";

declare variable $stdFONT as xs:string external := 'Arial';
declare variable $stdFONTptSZ as xs:decimal external;
declare variable $stdFONTcol as xs:string external :='black';

declare variable $axlabFONTcol as xs:string external :='black';

declare variable $pathSTRK as xs:float external;

declare variable $gridCOL as xs:string external := 'rgb(159,159,159)';

declare variable $sheetNAME as xs:string external := 'DATASHEET CURVES';

declare variable $sheetrID := //b:sheet[@name=$sheetNAME]/@r:id/data();
declare variable $sheetTGT := doc(concat(substring-before(document-uri(.),'workbook.xml'),'_rels/workbook.xml.rels'))//rels:Relationship[@Id=$sheetrID]/@Target/data();
declare variable $sheetFILE := doc(concat(substring-before(document-uri(.),'workbook.xml'),$sheetTGT));

declare variable $SHTdwgsrID := $sheetFILE//b:drawing/@r:id/data();
declare variable $SHTdwgsTGT := doc(concat(substring-before(document-uri(.),'workbook.xml'),'worksheets/_rels',substring-after($sheetTGT,'worksheets'),'.rels'))//rels:Relationship[@Id=$SHTdwgsrID]/@Target/data();
declare variable $SHTdwgsFILE := doc(concat(substring-before(document-uri(.),'workbook.xml'),substring-after($SHTdwgsTGT,'../')));

declare variable $colWIDTHdef external := 9.14;
declare variable $rowHEIGHTdef external := $sheetFILE//sheetFormatPr/@defaultRowHeight/data() cast as xs:decimal;

declare variable $chartAREAwd external := local:chartWIDTH() cast as xs:decimal;
declare variable $chartAREAht external := local:chartHEIGHT() cast as xs:decimal;

declare variable $plotAREAwd as xs:float external;
declare variable $plotAREAht as xs:float external;


declare function local:svgTITLE($TITLE)
    {element title
        {text {$TITLE}
        }
    };

declare function local:svgPATH($pathCOL, $pathSTRK, $dCMD, $dXcoord, $dYcoord)
    {element path
        {attribute stroke {$pathCOL},
         attribute stroke-width {$pathSTRK},
         attribute d {$dCMD, $dXcoord, $dYcoord}
        }
    };

declare function local:svgRECT($rectXorg,$rectYorg,$rectWD,$rectHT,$rectFILLcol,$rectSTKcol,$rectSTKwd)
    {element rect
        {attribute x {$rectXorg},
        attribute y {$rectYorg},
        attribute width {$rectWD},
        attribute height{$rectHT},
        attribute fill{$rectFILLcol},
        attribute stroke{$rectSTKcol},
        attribute stroke-width{$rectSTKwd}
        }
    };

declare function local:svgTEXT($txtSTYLE, $txtFONT, $txtSIZE, $txtCOL,$txtXpos,$txtYpos,$txtTEXT)
    {element text
        {attribute x {$txtXpos},
        attribute y {$txtYpos},
        attribute style {$txtSTYLE},
        attribute font-family {$txtFONT},
        attribute font-size {$txtSIZE},
        attribute fill {$txtCOL},
        text {$txtTEXT}
        }
    };

declare function local:plotTSPAN($txtSTRNG)
    {element tspan
        {attribute baseline-shift {'sub'},
        attribute font-size {'0.18224'},
        text {$txtSTRNG}
        }
    };

declare function local:chartWIDTH()
    {for $chartNAMES in $SHTdwgsFILE//xdr:cNvPr[contains(@name, 'Chart')]
    let $chartFRcol as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:from/xdr:col/text() cast as xs:integer
    let $chartFOFFcol as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:from/xdr:coloff/text() cast as xs:integer

    let $chartTOcol as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:to/xdr:col/text() cast as xs:integer
    let $chartTOFFcol as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:to/xdr:coloff/text() cast as xs:integer

    for $chartCOLUMNS in $chartFRcol to $chartTOcol
        for $colWIDTHS in $sheetFILE//col
        where ($chartCOLUMNS ge $colWIDTHS//col/@min cast as xs:integer) and ($chartCOLUMNS le $sheetFILE//@max cast as xs:integer)
        let $chartAREAwdCUST := sum($colWIDTHS/@width/data() cast as xs:float)
    for $chartCOLUMNS in $chartFRcol to $chartTOcol
        for $colWIDTHS in $sheetFILE//col
        where ($chartCOLUMNS le $colWIDTHS//col/@min cast as xs:integer) or ($chartCOLUMNS ge $sheetFILE//@max cast as xs:integer)
        let $chartAREAwdDEF := count($colWIDTHS) * $colWIDTHdef
    (:the offset values below are in EMU and need conversion:)
    return ($chartAREAwdCUST + $chartAREAwdDEF - $chartFOFFcol + $chartTOFFcol)
    };

declare function local:chartHEIGHT()
    {for $chartNAMES in $SHTdwgsFILE//xdr:cNvPr[contains(@name, 'Chart')]
    let $chartFRrow as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:from/xdr:row/text() cast as xs:integer
    let $chartFOFFrow as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:from/xdr:rowoff/text() cast as xs:integer

    let $chartTOrow as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:to/xdr:row/text() cast as xs:integer
    let $chartTOFFrow as xs:integer := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:to/xdr:rowoff/text() cast as xs:integer 

    for $chartROWS in $chartFRrow to $chartTOrow
    (:the offset values below are in EMU and need conversion:)
    return (sum($chartROWS) *  $rowHEIGHTdef - $chartFOFFrow + $chartTOFFrow)
    };
    
    for $chartNAMES in $SHTdwgsFILE//xdr:cNvPr[contains(@name, 'Chart')]
    let $chartFRrow := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:from/xdr:row/text()    
    let $chartFRcol := $chartNAMES/ancestor::xdr:graphicFrame/preceding-sibling::xdr:from/xdr:col/text()

    order by $chartFRrow, $chartFRcol

    let $chartrID := $chartNAMES/ancestor::xdr:graphicFrame//c:chart/@r:id/data()
    let $chartTGT := doc(concat(substring-before(document-uri(.),'workbook.xml'),'drawings/_rels',substring-after($SHTdwgsTGT,'drawings'),'.rels'))//rels:Relationship[@Id=$chartrID]/@Target/data() cast as xs:string
    let $chartFILE := doc(concat(substring-before(document-uri(.),'workbook.xml'),substring-after($chartTGT,'../')))

    let $plotXOrig := (try {($chartAREAwd - $plotAREAwd) div 2} catch * {$chartAREAwd * $chartFILE//plotArea//c:x/@val/data() cast as xs:float})
    let $plotYOrig := (try {($chartAREAht - $plotAREAht) div 2} catch * {$chartAREAht * $chartFILE//plotArea//c:y/@val/data() cast as xs:float})

    return
    document
    {
    element svg{
    attribute width {$chartAREAwd},
    attribute height {$chartAREAht},
    attribute viewBox {concat('0 0', $chartAREAwd, $chartAREAht)},
    attribute version {'1.1'},
    attribute xlink {'http://www.w3.org/1999/xlink'},
    text{
    let $chartTITLE := $chartFILE//c:chartSpace/c:chart/c:title//a:t/string()
    return local:svgTITLE($chartTITLE),

    for $AXES at $axNUM in $chartFILE//c:valAx
        let $axMAX := $AXES/c:scaling/c:max/@val/data()
        let $axMIN := $AXES/c:scaling/c:min/@val/data()
        let $axMINOR := $AXES//c:minorUnit/@val/data()
        let $axMAJOR := $AXES//c:majorUnit/@val/data()
        let $gridCOUNT := fn:round(($axMAX - $axMIN) div $axMINOR) cast as xs:integer
        
        for $gridLINE in 1 to ($gridCOUNT - 1)
        return
        (switch ($axNUM)
        case 1 return (local:svgPATH(
                $gridCOL,
                $pathSTRK div 2,
                ('M','l'),
                $plotXOrig + ($gridLINE div $gridCOUNT * $plotAREAwd),
                ($plotYOrig,($plotYOrig + $plotAREAht))
                ),
                if ($gridLINE mod 2 eq 0) then
                    local:svgTEXT(
                    'text-anchor: middle',
                    $stdFONT,
                    try {$stdFONTptSZ} catch * {$AXES//c:txPr//@sz/data() div 100 cast as xs:decimal},
                    $axlabFONTcol,
                    $plotXOrig + ($gridLINE div $gridCOUNT * $plotAREAwd),
                    $plotYOrig,
                    $axMIN + ($gridLINE * $axMINOR)
                    )
                else ()
                )
         case 2 return (local:svgPATH(
                $gridCOL,
                $pathSTRK div 2,
                ('M','l'),
                ($plotXOrig,
                ($plotXOrig + $plotAREAwd)),
                $plotYOrig + ($gridLINE div $gridCOUNT * $plotAREAht)
                ),
                if ($axNUM eq 2) then
                    local:svgTEXT(
                    'text-anchor: middle',
                    $stdFONT,
                    try {$stdFONTptSZ} catch * {$AXES//c:txPr//@sz/data() div 100 cast as xs:decimal},
                    $axlabFONTcol,
                    $plotXOrig,
                    $plotYOrig + ($gridLINE div $gridCOUNT * $plotAREAht),
                    $axMIN + ($gridLINE * $axMINOR)
                    )
                else ()
                )
                default return ()
            ),

    for $plotDIMS in $chartFILE//c:plotArea
    return local:svgRECT(
        (try {($chartAREAwd - $plotAREAwd) div 2} catch * {$chartAREAwd * $chartFILE//plotArea//c:x/@val/data() cast as xs:float}),
        (try {($chartAREAht - $plotAREAht) div 2} catch * {$chartAREAht * $chartFILE//plotArea//c:y/@val/data() cast as xs:float}),
        (try {$plotAREAwd} catch * {$chartAREAwd * $chartFILE//plotArea//c:w/@val/data() cast as xs:float}),
        (try {$plotAREAht} catch * {$chartAREAht * $chartFILE//plotArea//c:h/@val/data() cast as xs:float}),
        'none',
        'black',
        $pathSTRK),

(:find drawings file via relationships and retrieve text box info:)
    let $UshapesID := $chartFILE//c:userShapes/@r:id/data()
    let $chartFILE := substring-after(document-uri(.),'/xl/charts/')
    let $chartRELS := concat(substring-before(document-uri(.),$chartFILE),'_rels/',$chartFILE,'.rels') cast as xs:anyURI
    let $chartDWGS := concat(substring-before(document-uri(.),'charts/'),substring-after(doc($chartRELS)/rels:Relationships/rels:Relationship[@Id=$UshapesID]/@Target/data(),'../')) cast as xs:anyURI

    for $txtBOX in doc($chartDWGS)//cdr:relSizeAnchor
    where $txtBOX//@txBox eq '1'
        let $txtBOXx0 := $txtBOX/cdr:from/cdr:x
        let $txtBOXy0 := $txtBOX/cdr:from/cdr:y
        let $txtBOXx1 := $txtBOX/cdr:to/cdr:x
        let $txtBOXy1 := $txtBOX/cdr:to/cdr:y
            return (local:svgRECT($txtBOXx0,$txtBOXy0,$txtBOXx1,$txtBOXy1,'none','black',0),
                let $txtPOSx := $txtBOXx0 + (($txtBOXx1 - $txtBOXx0) div 2)
                let $txtPOSy := $txtBOXy0 + (($txtBOXy1 - $txtBOXy0) div 2)
                return local:svgTEXT(
                    'text-anchor: middle',
                    try {$stdFONTptSZ} catch * {},
                    'black',
                    $txtBOXx0,
                    $txtBOXy0,
                    {for $txtSTRNG in $txtBOX//a:t
                    return 
                    (if ($txtSTRNG/preceding-sibling::a:rPr[1]/@baseline = -25000) then local:plotTSPAN($txtSTRNG/text()) else $txtSTRNG/text())
             })
            )
       )
))},
(:pair x and y coords for SVG path by matching c:pt idx index values:)
for $series in c:chartSpace//c:ser
return
 element path{
        attribute stroke {'black'},
        attribute stroke-width {'0.018'},
        attribute d {for $serCOORDs in $series//c:numCache/c:pt
        let $ptIDX := $serCOORDs/@idx cast as xs:integer
        group by $ptIDX
        stable order by $ptIDX
        return concat(if ($ptIDX=0) then 'M' else 'L',$serCOORDs[@idx=$ptIDX][1]/c:v,' ',$serCOORDs[@idx=$ptIDX][2]/c:v)
        }
    }
}
}
