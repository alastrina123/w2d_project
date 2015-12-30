xquery version "3.0";

declare namespace xs="http://www.w3.org/2001/XMLSchema";
declare namespace c="http://schemas.openxmlformats.org/drawingml/2006/chart";
declare namespace a="http://schemas.openxmlformats.org/drawingml/2006/main";
declare namespace r="http://schemas.openxmlformats.org/officeDocument/2006/relationships";
declare namespace cdr="http://schemas.openxmlformats.org/drawingml/2006/chartDrawing";
declare namespace rels="http://schemas.openxmlformats.org/package/2006/relationships";

declare default element namespace "http://www.w3.org/2000/svg";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization"; 
declare option output:method "xml"; 
declare option output:indent "yes"; 
declare option output:omit-xml-declaration "no";
declare option output:encoding "UTF-8";

declare function local:plotTSPAN($txtSTRNG)
    {element tspan
        {attribute baseline-shift {'sub'},
        attribute font-size {'0.18224'},
        text {$txtSTRNG}
        }
    };

declare function local:plotPATH(){
    element path{
        attribute stroke {'rgb(159, 159, 159)'},
        attribute stroke-width {'0.3'},
        attribute d {}
}};

declare function local:plotHORZ($ymax, $ymin, $yAXlab,$HgridYcord){
    element text{
        attribute x {'1.3'},
        attribute y {$HgridYcord + 0.1},
        attribute style {'text-anchor: end'},
        attribute font-family {'Arial'},
        attribute font-size {'0.28224'},
        attribute fill {'black'},
        text {xs:float($yAXlab)}},
    element path{
        attribute stroke {'rgb(159, 159, 159)'},
        attribute stroke-width {'0.00875'},
        attribute d {'M 1.35',
                    $HgridYcord,
                    'l 5.3 0 '}}
};

declare function local:plotVERT($xmax, $xmin, $xAXlab,$VgridXcord){
    element text{
        attribute x {$VgridXcord},
        attribute y {'5.95'},
        attribute style {'text-anchor: middle'},
        attribute font-family {'Arial'},
        attribute font-size {'0.28224'},
        attribute fill {'black'},
        text {xs:float($xAXlab)}},
    element path{
        attribute stroke {'rgb(159, 159, 159)'},
        attribute stroke-width {'0.00875'},
        attribute d {'M',$VgridXcord, '0.35 l 0 5.3 '}}
};

declare function local:plotRECT($RECTx0,$RECTy0,$RECTx1,$RECTy1){
    element rect{
        attribute x {$RECTx0 * 8},
        attribute y {$RECTy0 * 6},
        attribute width{($RECTx1 - $RECTx0) * 8},
        attribute height{($RECTy1 - $RECTy0) * 6},
        attribute fill{'none'},
        attribute stroke{'black'},
        attribute stroke-width{0.018}
    }
};

(:let $BOXdims := //c:layout

for $layout in $BOXdims//c:layoutTarget[@val='inner']
let $BOXwd := $layout/following-sibling::c:w[1]/@val/data()
let $BOXht := $layout/following-sibling::c:h[1]/@val/data():)

for $chartSPACE in //c:chartSpace

return document

{(:SVG header info:)
<svg width="8cm" height="6cm" viewBox="0 0 8 6" xmlns="http://www.w3.org/2000/svg" version="1.1"
 xmlns:xlink="http://www.w3.org/1999/xlink">

{(:chart axis step values and gridlines:)
for $chartAXES in //c:chart/c:plotArea

let $xmax := //c:valAx[1]/c:scaling/c:max/@val/data()
let $xmin := //c:valAx[1]/c:scaling/c:min/@val/data()
let $xMINOR := //c:valAx[1]//c:minorUnit/@val/data()
let $VgridCNT := fn:round(($xmax - $xmin) div $xMINOR) cast as xs:integer
for $Vline in 1 to ($VgridCNT - 1)
  return (local:plotVERT($xmax, $xmin,  $xmin + ($Vline * $xMINOR),(1.35 + (($Vline * 5.3) div $VgridCNT)))),

let $ymax := //c:valAx[2]/c:scaling/c:max/@val/data()
let $ymin := //c:valAx[2]/c:scaling/c:min/@val/data()
let $yMINOR := //c:valAx[2]//c:minorUnit/@val/data()
let $HgridCNT := fn:round(($ymax - $ymin) div $yMINOR) cast as xs:integer
for $Hline in 1 to ($HgridCNT - 1)
  return (local:plotHORZ($ymax, $ymin,  $ymin + ($Hline * $yMINOR),(0.35 + (($Hline * 5.3) div $HgridCNT))))}

{(:find drawings file via relationships and retrieve text box info:)
for $txtREFs in //c:userShapes
let $RELid := $txtREFs/@r:id/data()
let $thisDOC := substring-after(document-uri(.),'/xl/charts/')
let $RELfile := concat(substring-before(document-uri(.),$thisDOC),'_rels/',$thisDOC,'.rels') cast as xs:anyURI
let $DRAWfile := concat(substring-before(document-uri(.),'charts/'),substring-after(doc($RELfile)/rels:Relationships/rels:Relationship[@Id=$RELid]/@Target/data(),'../')) cast as xs:anyURI
return
    (for $txtBOX in doc($DRAWfile)//cdr:relSizeAnchor
    where $txtBOX//@txBox="1"
    let $txtBOXx0 := $txtBOX/cdr:from/cdr:x
    let $txtBOXy0 := $txtBOX/cdr:from/cdr:y
    let $txtBOXx1 := $txtBOX/cdr:to/cdr:x
    let $txtBOXy1 := $txtBOX/cdr:to/cdr:y
    return (local:plotRECT($txtBOXx0,$txtBOXy0,$txtBOXx1,$txtBOXy1),
        (let $txtPOSx := $txtBOXx0 + (($txtBOXx1 - $txtBOXx0) div 2)
        let $txtPOSy := $txtBOXy0 + (($txtBOXy1 - $txtBOXy0) div 2)
        return
            (<text x = "{$txtPOSx * 8}" y = "{$txtPOSy * 6}" style = "text-anchor: middle" font-family = "Arial" font-size = "0.28224" fill = "black">
            {for $txtSTRNG in $txtBOX//a:t
                return 
                    (if ($txtSTRNG/preceding-sibling::a:rPr[1]/@baseline = -25000) then local:plotTSPAN($txtSTRNG/text()) else $txtSTRNG/text())
             }       
            </text>
            )
       )
))}
{(:pair x and y coords for SVG path by matching c:pt idx index values:)
for $series in c:chartSpace//c:ser
return
 element path{
        attribute stroke {'black'},
        attribute stroke-width {'0.018'},
        attribute d {for $serCOORDs in $series//c:numCache/c:pt
        let $ptIDX := $serCOORDs/@idx
        group by $ptIDX
        stable order by $ptIDX
        return concat(if ($ptIDX=0) then 'M' else 'L',$serCOORDs[@idx=$ptIDX][1]/c:v,' ',$serCOORDs[@idx=$ptIDX][2]/c:v)
                    }
                }
}
{(:plot area reticle:)
let $PLOTx0 := 1.35 div 8
let $PLOTy0 := 0.35 div 6
let $PLOTx1 := $PLOTx0 + (5.3 div 8)
let $PLOTy1 := $PLOTy0 + (5.3 div 6)
return local:plotRECT($PLOTx0,$PLOTy0,$PLOTx1,$PLOTy1)}
 
</svg>
}
