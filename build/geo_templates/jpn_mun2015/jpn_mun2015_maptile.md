**maptile  Geography: jpn_mun2015**

# Description

**jpn_mun2015** generates a map of Japanese municipalities as of 2015 Population Census (October 1, 2015).

It does not display the Northern Territories or Ogasawara Village for ease of viewing.

# Geographic ID variables


|Geographic ID|Description|
|---|---|
|`mun`|5-digit municipality codes (numeric)|


Si-ku-cho-son (municipality) identification code (JIS X0402) is used as municipality code. Check digit is not included.


reference:  
[http://www.soumu.go.jp/denshijiti/code.html](http://www.soumu.go.jp/denshijiti/code.html)  
[http://nlftp.mlit.go.jp/ksj-e/gml/codelist/AdminAreaCd.html](http://nlftp.mlit.go.jp/ksj-e/gml/codelist/AdminAreaCd.html)


# Geography-Specific Options


|Option|Description|
|---|---|
|`district`| It outputs ordinance-designated cities in district level |
|`compressed `| It moves Okinawa prefecture to the top left of the map |

As default, ordinance-designated cities are outputed in city level. A full list of ordinance-designated cities is available in [this page](http://www.soumu.go.jp/main_sosiki/jichi_gyousei/bunken/shitei_toshi-ichiran.html).

# Author

Chigusa Okamoto  
okamoto-chigusa546@g.ecc.u-tokyo.ac.jp  
okamoto.chigusa.econ@gmail.com


Michael Stepner  
stepner@mit.edu  
michaelstepner@gmail.com

# Source

- Takashi Kirimura, [Municipality Map Maker Web version (MMM4W)] (http://www.tkirimura.com/mmm/)
- Municipality shapefiles (WGS;  lightweight size; October 1, 2015) 



# License

If you would like to redistribute the geographic template with replication or processing, please refer to MMM4W. All code and documentation in this template is released into the public domain using the terms of the [Unlicense](http://unlicense.org/).