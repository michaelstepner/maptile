**maptile  Geography: jpn_pref**

# Description

**jpn_pref** generates a map of Japan prefectures.

It does not display Northern Territories and Ogasawara Village for ease of viewing.

# Geographic ID variables


|Geographic ID|Description|
|---|---|
|`pref`|2-digit prefecture codes (numeric)|
|`prefname `|prefecture name in English |
|`prefname_jpn `|prefecture name in Japanese |



To-do-fu-ken (prefecture) identification code (JIS X0401) is used as prefecture code. JIS X0401 is the latter part of ISO 3166-2:JP after a hyphen. Type names of prefectures (i.e., To, Fu, Ken) are removed from prefname and prefname_jpn.



reference:  
[http://www.soumu.go.jp/denshijiti/code.html](http://www.soumu.go.jp/denshijiti/code.html)  
[https://www.iso.org/obp/ui/#iso:code:3166:JP](https://www.iso.org/obp/ui/#iso:code:3166:JP)
[http://nlftp.mlit.go.jp/ksj-e/gml/codelist/PrefCd.html](http://nlftp.mlit.go.jp/ksj-e/gml/codelist/PrefCd.html)

# Geography-Specific Options


|Option|Description|
|---|---|
|`geoid(varname)`| It specifies the geographic ID variable to use; default is **geoid(pref)** |
|`simple `| It only displays large islands greater than 500 squared kilometers |
|`compressed `| It moves Okinawa prefecture to the top left of the map |





# Author

Chigusa Okamoto  
okamoto-chigusa546@g.ecc.u-tokyo.ac.jp  
okamoto.chigusa.econ@gmail.com  
(The person processing the data)

Michael Stepner  
stepner@mit.edu  
michaelstepner@gmail.com


# Source
- National Land Numerical Information download service 
- [National Land Numerical Information  Administrative Zones Data](http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-N03-v2_3.html) 
　
	


# License
This map is based on the Digital Map(Basic Geospatial Informaion) published by Geospatial Information Authority of Japan with its approval under the article30 of The Survey Act (Approval Number JYOU-SHI No.1575 2018). For secondary use of this geographic template, please refer to [the website of Geospatial Information Authority of Japan](http://www.gsi.go.jp/). All code and documentation in this template is released into the public domain using the terms of the [Unlicense](http://unlicense.org/).