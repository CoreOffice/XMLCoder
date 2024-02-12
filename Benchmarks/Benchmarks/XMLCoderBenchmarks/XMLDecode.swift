import XMLCoder
import Foundation

struct Companies: Codable {
    struct Company: Codable {
        struct Address: Codable {
            let street: String
            let city: String
            let state: String
            let zip: String
        }

        let name: String
        let address: Address
        let ceo: String
        let dateCreated: Date
    }

    let company: [Company]
}

func runXMLDecoder() throws {
    let decoder = XMLDecoder()
	let formatter = DateFormatter()
	formatter.dateFormat = "yyyy-MM-dd"
	decoder.dateDecodingStrategy = .formatted(formatter)
    let data = try decoder.decode(Companies.self, from: testData.data(using: .utf8)!)
    guard data.company.count == 100 else {
        fatalError("Invalid test expectation")
    }
}

fileprivate let testData = """
<ctRoot>
	<company>
		<name>Known International S.A</name>
		<address>
			<street>7246 Anthony</street>
			<city>Bel Air</city>
			<state>Montana</state>
			<zip>NJ50096</zip>
		</address>
		<ceo>Calista Harr</ceo>
		<dateCreated>2017-05-12</dateCreated>
	</company>
	<company>
		<name>Ps </name>
		<address>
			<street>4932 Borsden Circle</street>
			<city>Kenosha</city>
			<state>New Hampshire</state>
			<zip>NY36570</zip>
		</address>
		<ceo>Lucia Corey</ceo>
		<dateCreated>1976-09-04</dateCreated>
	</company>
	<company>
		<name>Causes Software LLC</name>
		<address>
			<street>2743 Rushmere Road</street>
			<city>Downey</city>
			<state>Tennessee</state>
			<zip>NV31214</zip>
		</address>
		<ceo>Nelson Ouellette</ceo>
		<dateCreated>2001-01-16</dateCreated>
	</company>
	<company>
		<name>Blah Mutual Corp</name>
		<address>
			<street>2110 Turncroft Lane</street>
			<city>Yonkers</city>
			<state>Florida</state>
			<zip>WA20155</zip>
		</address>
		<ceo>Tereasa Pettit</ceo>
		<dateCreated>2001-01-03</dateCreated>
	</company>
	<company>
		<name>Sciences </name>
		<address>
			<street>0476 Redthorn Road</street>
			<city>Eugene</city>
			<state>South Carolina</state>
			<zip>KY08303</zip>
		</address>
		<ceo>Wynona King</ceo>
		<dateCreated>2022-11-26</dateCreated>
	</company>
	<company>
		<name>Cs Company</name>
		<address>
			<street>5463 Knowle Circle</street>
			<city>Cathedral City</city>
			<state>Florida</state>
			<zip>NM06696</zip>
		</address>
		<ceo>Grover Tafoya</ceo>
		<dateCreated>1975-02-23</dateCreated>
	</company>
	<company>
		<name>Emperor Stores Inc</name>
		<address>
			<street>8690 Gould Road</street>
			<city>Toledo</city>
			<state>Hawaii</state>
			<zip>LA95381</zip>
		</address>
		<ceo>Verna Bowler</ceo>
		<dateCreated>1978-10-20</dateCreated>
	</company>
	<company>
		<name>Garlic Energy LLC</name>
		<address>
			<street>7112 Goughs Avenue</street>
			<city>Lancaster</city>
			<state>New Mexico</state>
			<zip>FL09641</zip>
		</address>
		<ceo>Vi Thrash</ceo>
		<dateCreated>1988-04-14</dateCreated>
	</company>
	<company>
		<name>Massive Stores GmbH</name>
		<address>
			<street>2534 Bosden Street</street>
			<city>Bonita Springs</city>
			<state>Oklahoma</state>
			<zip>OH07004</zip>
		</address>
		<ceo>Tandy Mcbee</ceo>
		<dateCreated>1992-11-11</dateCreated>
	</company>
	<company>
		<name>Surf Holdings Company</name>
		<address>
			<street>9698 Neild</street>
			<city>Fargo</city>
			<state>Colorado</state>
			<zip>AL70062</zip>
		</address>
		<ceo>Leopoldo Lowry</ceo>
		<dateCreated>2018-10-12</dateCreated>
	</company>
	<company>
		<name>Path Ltd</name>
		<address>
			<street>6727 Kelson Circle</street>
			<city>Hollywood</city>
			<state>Louisiana</state>
			<zip>MD44169</zip>
		</address>
		<ceo>Lesli Dietrich</ceo>
		<dateCreated>1994-12-06</dateCreated>
	</company>
	<company>
		<name>Detected GmbH</name>
		<address>
			<street>5810 Horderns Circle</street>
			<city>Palm Springs</city>
			<state>Arkansas</state>
			<zip>IA57090</zip>
		</address>
		<ceo>Karla Hyland</ceo>
		<dateCreated>2017-02-02</dateCreated>
	</company>
	<company>
		<name>Spies Stores </name>
		<address>
			<street>0683 Marland Circle</street>
			<city>Sarasota</city>
			<state>New Mexico</state>
			<zip>FL80124</zip>
		</address>
		<ceo>Perla Mcbee</ceo>
		<dateCreated>2004-09-19</dateCreated>
	</company>
	<company>
		<name>Tech LLC</name>
		<address>
			<street>4788 Back Avenue</street>
			<city>Gainesville</city>
			<state>Utah</state>
			<zip>WY86585</zip>
		</address>
		<ceo>Tomas Woo</ceo>
		<dateCreated>2005-07-29</dateCreated>
	</company>
	<company>
		<name>Rf Corporation</name>
		<address>
			<street>3037 Pear</street>
			<city>Lexington</city>
			<state>Georgia</state>
			<zip>TX26071</zip>
		</address>
		<ceo>Jeanelle Sander</ceo>
		<dateCreated>1987-08-06</dateCreated>
	</company>
	<company>
		<name>Soap Stores A.G</name>
		<address>
			<street>6559 Back Street</street>
			<city>Albany</city>
			<state>Maine</state>
			<zip>NV91407</zip>
		</address>
		<ceo>Dominica Peeples</ceo>
		<dateCreated>1995-03-01</dateCreated>
	</company>
	<company>
		<name>Professionals Corporation</name>
		<address>
			<street>3441 Rodney Circle</street>
			<city>McHenry</city>
			<state>New Mexico</state>
			<zip>NE76752</zip>
		</address>
		<ceo>Jesica Weathers</ceo>
		<dateCreated>2011-09-13</dateCreated>
	</company>
	<company>
		<name>Manufactured Corp</name>
		<address>
			<street>9543 Gosling Circle</street>
			<city>Syracuse</city>
			<state>New Mexico</state>
			<zip>OK70595</zip>
		</address>
		<ceo>Arnette Bishop</ceo>
		<dateCreated>1991-04-27</dateCreated>
	</company>
	<company>
		<name>Highways S.A</name>
		<address>
			<street>7666 Deacons</street>
			<city>Gastonia</city>
			<state>Pennsylvania</state>
			<zip>ND06984</zip>
		</address>
		<ceo>Rachell Horst</ceo>
		<dateCreated>1988-12-03</dateCreated>
	</company>
	<company>
		<name>Utils </name>
		<address>
			<street>8894 Brentnor Road</street>
			<city>Winter Haven</city>
			<state>Vermont</state>
			<zip>NY22467</zip>
		</address>
		<ceo>Carlie Fahey</ceo>
		<dateCreated>2020-12-09</dateCreated>
	</company>
	<company>
		<name>Figures </name>
		<address>
			<street>8372 Wyngate Avenue</street>
			<city>Burlington</city>
			<state>Maryland</state>
			<zip>OK50868</zip>
		</address>
		<ceo>Shameka Zink</ceo>
		<dateCreated>1977-09-27</dateCreated>
	</company>
	<company>
		<name>Classics Software S.A</name>
		<address>
			<street>8546 Cheam Avenue</street>
			<city>Augusta</city>
			<state>Connecticut</state>
			<zip>CO60895</zip>
		</address>
		<ceo>Elodia Thornburg</ceo>
		<dateCreated>2019-09-03</dateCreated>
	</company>
	<company>
		<name>Journalists SIA</name>
		<address>
			<street>9174 Hob</street>
			<city>Topeka</city>
			<state>Oklahoma</state>
			<zip>CO68708</zip>
		</address>
		<ceo>Lachelle Gagnon</ceo>
		<dateCreated>1992-10-05</dateCreated>
	</company>
	<company>
		<name>Acc Software </name>
		<address>
			<street>0072 Aber Road</street>
			<city>Charlotte</city>
			<state>New Hampshire</state>
			<zip>TN90616</zip>
		</address>
		<ceo>Carlita Owens</ceo>
		<dateCreated>2003-05-17</dateCreated>
	</company>
	<company>
		<name>Lime Energy Company</name>
		<address>
			<street>3694 Bollin</street>
			<city>Orange</city>
			<state>Idaho</state>
			<zip>MD26937</zip>
		</address>
		<ceo>Solange Cota</ceo>
		<dateCreated>1977-04-27</dateCreated>
	</company>
	<company>
		<name>Watched Stores </name>
		<address>
			<street>4709 Brazley Lane</street>
			<city>Abilene</city>
			<state>Rhode Island</state>
			<zip>PA99377</zip>
		</address>
		<ceo>Essie Farley</ceo>
		<dateCreated>2000-10-14</dateCreated>
	</company>
	<company>
		<name>Combat </name>
		<address>
			<street>4089 Canada Road</street>
			<city>Fresno</city>
			<state>North Carolina</state>
			<zip>ME51644</zip>
		</address>
		<ceo>Cristine Anthony</ceo>
		<dateCreated>1988-05-24</dateCreated>
	</company>
	<company>
		<name>Blackberry Inc</name>
		<address>
			<street>3767 Badminton Road</street>
			<city>Chicago</city>
			<state>Virginia</state>
			<zip>WI50400</zip>
		</address>
		<ceo>Lilliana Chambers</ceo>
		<dateCreated>2007-07-06</dateCreated>
	</company>
	<company>
		<name>Midwest A.G</name>
		<address>
			<street>7224 Globe Street</street>
			<city>College Station</city>
			<state>Massachusetts</state>
			<zip>AK01157</zip>
		</address>
		<ceo>Shizuko Dominquez</ceo>
		<dateCreated>2021-05-05</dateCreated>
	</company>
	<company>
		<name>Rebecca Energy S.A</name>
		<address>
			<street>8854 Cinamon</street>
			<city>Salem</city>
			<state>Maine</state>
			<zip>TX09054</zip>
		</address>
		<ceo>Wilber Eskridge</ceo>
		<dateCreated>1989-07-28</dateCreated>
	</company>
	<company>
		<name>Psychiatry Industries Company</name>
		<address>
			<street>5386 Woodseats Street</street>
			<city>Raleigh</city>
			<state>Alaska</state>
			<zip>NJ72141</zip>
		</address>
		<ceo>Tobias Dion</ceo>
		<dateCreated>1976-02-21</dateCreated>
	</company>
	<company>
		<name>Counts International </name>
		<address>
			<street>9618 Silverhey Avenue</street>
			<city>Sioux City</city>
			<state>New Jersey</state>
			<zip>IN29960</zip>
		</address>
		<ceo>Temple Murphy</ceo>
		<dateCreated>1974-11-11</dateCreated>
	</company>
	<company>
		<name>Christina International SIA</name>
		<address>
			<street>5463 Gillbrook Lane</street>
			<city>Melbourne</city>
			<state>Virginia</state>
			<zip>VA80719</zip>
		</address>
		<ceo>Barbara Sonnier</ceo>
		<dateCreated>2005-03-03</dateCreated>
	</company>
	<company>
		<name>Antenna Energy Pte. Ltd</name>
		<address>
			<street>4029 Honeysuckle Lane</street>
			<city>Erie</city>
			<state>Alaska</state>
			<zip>SC98046</zip>
		</address>
		<ceo>Henry Clem</ceo>
		<dateCreated>1988-03-22</dateCreated>
	</company>
	<company>
		<name>Boc Holdings B.V</name>
		<address>
			<street>3032 Orrell Road</street>
			<city>Medford</city>
			<state>West Virginia</state>
			<zip>AK60134</zip>
		</address>
		<ceo>Lia Rasmussen</ceo>
		<dateCreated>1979-04-18</dateCreated>
	</company>
	<company>
		<name>Actual Mutual B.V</name>
		<address>
			<street>7057 Deer Street</street>
			<city>Fremont</city>
			<state>North Carolina</state>
			<zip>NE26947</zip>
		</address>
		<ceo>Normand Ricker</ceo>
		<dateCreated>1991-07-23</dateCreated>
	</company>
	<company>
		<name>Si B.V</name>
		<address>
			<street>5739 Nunthorpe Lane</street>
			<city>Melbourne</city>
			<state>Maryland</state>
			<zip>AL13695</zip>
		</address>
		<ceo>Shawnee Turnbull</ceo>
		<dateCreated>1999-01-30</dateCreated>
	</company>
	<company>
		<name>Hotmail Company</name>
		<address>
			<street>6908 Unwin Circle</street>
			<city>Killeen</city>
			<state>Virginia</state>
			<zip>TX65173</zip>
		</address>
		<ceo>Lyndon Stone-Cochran</ceo>
		<dateCreated>2004-03-30</dateCreated>
	</company>
	<company>
		<name>Plug Energy A.G</name>
		<address>
			<street>3809 Sunlight Lane</street>
			<city>Trenton</city>
			<state>Minnesota</state>
			<zip>VT17069</zip>
		</address>
		<ceo>Ernie Lovett</ceo>
		<dateCreated>1973-09-15</dateCreated>
	</company>
	<company>
		<name>Characters Holdings LLC</name>
		<address>
			<street>2589 Derwen Street</street>
			<city>Cedar Rapids</city>
			<state>North Carolina</state>
			<zip>OH70168</zip>
		</address>
		<ceo>Arica Sherrod</ceo>
		<dateCreated>1970-01-30</dateCreated>
	</company>
	<company>
		<name>Standing International SIA</name>
		<address>
			<street>2908 Bernisdale</street>
			<city>Henderson</city>
			<state>Indiana</state>
			<zip>TX98606</zip>
		</address>
		<ceo>Beulah Hart</ceo>
		<dateCreated>2023-07-15</dateCreated>
	</company>
	<company>
		<name>Ht Energy Ltd</name>
		<address>
			<street>3554 Racecourse Avenue</street>
			<city>Clarksville</city>
			<state>Oklahoma</state>
			<zip>SD99739</zip>
		</address>
		<ceo>Modesto Hinson</ceo>
		<dateCreated>2016-09-14</dateCreated>
	</company>
	<company>
		<name>Affordable Software LLC</name>
		<address>
			<street>8955 Erica</street>
			<city>Santa Maria</city>
			<state>Colorado</state>
			<zip>SD00318</zip>
		</address>
		<ceo>Alvaro Huntley</ceo>
		<dateCreated>1994-04-27</dateCreated>
	</company>
	<company>
		<name>Devon LLC</name>
		<address>
			<street>1097 Blair Street</street>
			<city>Charlotte</city>
			<state>Wisconsin</state>
			<zip>MT01111</zip>
		</address>
		<ceo>Chasity Tuck</ceo>
		<dateCreated>1985-04-18</dateCreated>
	</company>
	<company>
		<name>Wanted Software </name>
		<address>
			<street>1662 Eastbourne Road</street>
			<city>Frederick</city>
			<state>Ohio</state>
			<zip>OH72441</zip>
		</address>
		<ceo>Tammi Mcnamara</ceo>
		<dateCreated>1975-11-22</dateCreated>
	</company>
	<company>
		<name>Hotel Mutual A.G</name>
		<address>
			<street>6850 Dell Circle</street>
			<city>Victorville</city>
			<state>Arkansas</state>
			<zip>AL38687</zip>
		</address>
		<ceo>Dorla Williams</ceo>
		<dateCreated>1977-12-09</dateCreated>
	</company>
	<company>
		<name>Lycos </name>
		<address>
			<street>4288 Haley</street>
			<city>Racine</city>
			<state>Texas</state>
			<zip>MD04440</zip>
		</address>
		<ceo>Armanda Koehler</ceo>
		<dateCreated>2003-09-13</dateCreated>
	</company>
	<company>
		<name>Approaches Industries S.A</name>
		<address>
			<street>3962 Baron Lane</street>
			<city>Elkhart</city>
			<state>New Jersey</state>
			<zip>NV91449</zip>
		</address>
		<ceo>Lidia Almond</ceo>
		<dateCreated>2023-02-16</dateCreated>
	</company>
	<company>
		<name>Downloadable S.A</name>
		<address>
			<street>7370 Merlyn Lane</street>
			<city>Seattle</city>
			<state>Tennessee</state>
			<zip>MO51368</zip>
		</address>
		<ceo>Roseanne Benefield</ceo>
		<dateCreated>2018-09-19</dateCreated>
	</company>
	<company>
		<name>Abstract GmbH</name>
		<address>
			<street>5235 Euston Street</street>
			<city>Memphis</city>
			<state>Montana</state>
			<zip>MD46124</zip>
		</address>
		<ceo>Ardith Darling</ceo>
		<dateCreated>1979-09-28</dateCreated>
	</company>
	<company>
		<name>Lease Corp</name>
		<address>
			<street>4506 Katherine</street>
			<city>Evansville</city>
			<state>New York</state>
			<zip>KS94523</zip>
		</address>
		<ceo>Dollie Fallon</ceo>
		<dateCreated>2001-03-16</dateCreated>
	</company>
	<company>
		<name>Lesser Ltd</name>
		<address>
			<street>2169 Braddyll Lane</street>
			<city>Memphis</city>
			<state>Missouri</state>
			<zip>MD76541</zip>
		</address>
		<ceo>Yasuko Coffey</ceo>
		<dateCreated>2001-09-26</dateCreated>
	</company>
	<company>
		<name>Dx Software Corporation</name>
		<address>
			<street>1445 Upton Circle</street>
			<city>Daly City</city>
			<state>Texas</state>
			<zip>IA72709</zip>
		</address>
		<ceo>Velva Rock</ceo>
		<dateCreated>2003-01-03</dateCreated>
	</company>
	<company>
		<name>Webster International </name>
		<address>
			<street>5040 Oakdale</street>
			<city>Coral Springs</city>
			<state>Minnesota</state>
			<zip>ME87181</zip>
		</address>
		<ceo>Haywood Woodruff</ceo>
		<dateCreated>2006-09-24</dateCreated>
	</company>
	<company>
		<name>Surgical Company</name>
		<address>
			<street>6169 Bilbrook Road</street>
			<city>Chula Vista</city>
			<state>New Jersey</state>
			<zip>ID65614</zip>
		</address>
		<ceo>Rolf Schiller</ceo>
		<dateCreated>1995-01-24</dateCreated>
	</company>
	<company>
		<name>Concepts Stores </name>
		<address>
			<street>8402 Peel</street>
			<city>Pompano Beach</city>
			<state>Mississippi</state>
			<zip>TX93462</zip>
		</address>
		<ceo>Kacey Treadwell</ceo>
		<dateCreated>2003-02-08</dateCreated>
	</company>
	<company>
		<name>Curriculum Industries Corporation</name>
		<address>
			<street>7134 Back Circle</street>
			<city>Antioch</city>
			<state>Montana</state>
			<zip>MA13056</zip>
		</address>
		<ceo>Wilson Skeen</ceo>
		<dateCreated>1998-11-22</dateCreated>
	</company>
	<company>
		<name>Verzeichnis Software Corp</name>
		<address>
			<street>6441 Martlew Circle</street>
			<city>Brownsville</city>
			<state>Nevada</state>
			<zip>CO68926</zip>
		</address>
		<ceo>Latrice Fugate</ceo>
		<dateCreated>1996-02-14</dateCreated>
	</company>
	<company>
		<name>Compilation International LLC</name>
		<address>
			<street>4372 Roseleigh Lane</street>
			<city>Syracuse</city>
			<state>Colorado</state>
			<zip>WV67698</zip>
		</address>
		<ceo>Yan Stearns</ceo>
		<dateCreated>1980-01-19</dateCreated>
	</company>
	<company>
		<name>Exit Mutual Inc</name>
		<address>
			<street>9096 War</street>
			<city>Santa Cruz</city>
			<state>Idaho</state>
			<zip>TX77737</zip>
		</address>
		<ceo>Robert Ledford</ceo>
		<dateCreated>2017-04-23</dateCreated>
	</company>
	<company>
		<name>Inputs International Pte. Ltd</name>
		<address>
			<street>3914 Jowett Street</street>
			<city>Costa Mesa</city>
			<state>Massachusetts</state>
			<zip>NH47843</zip>
		</address>
		<ceo>Adolph Steward</ceo>
		<dateCreated>1984-09-18</dateCreated>
	</company>
	<company>
		<name>Recover Software Company</name>
		<address>
			<street>9303 Pentland Street</street>
			<city>Huntington</city>
			<state>Idaho</state>
			<zip>AZ57314</zip>
		</address>
		<ceo>Lore Mcleod</ceo>
		<dateCreated>1979-08-06</dateCreated>
	</company>
	<company>
		<name>Emma Pte. Ltd</name>
		<address>
			<street>2835 Hollowood</street>
			<city>Palmdale</city>
			<state>Georgia</state>
			<zip>NV09689</zip>
		</address>
		<ceo>Shannan Usher</ceo>
		<dateCreated>2008-08-09</dateCreated>
	</company>
	<company>
		<name>Suppliers International A.G</name>
		<address>
			<street>9112 Pine Lane</street>
			<city>San Antonio</city>
			<state>New Hampshire</state>
			<zip>MD48555</zip>
		</address>
		<ceo>Criselda Booth-Joyner</ceo>
		<dateCreated>2003-10-10</dateCreated>
	</company>
	<company>
		<name>Tba </name>
		<address>
			<street>2521 Pritchard Circle</street>
			<city>Syracuse</city>
			<state>Connecticut</state>
			<zip>RI89406</zip>
		</address>
		<ceo>Weston Thomsen</ceo>
		<dateCreated>2018-07-18</dateCreated>
	</company>
	<company>
		<name>Leonard SIA</name>
		<address>
			<street>9741 Casson Street</street>
			<city>Akron</city>
			<state>Maine</state>
			<zip>OR53897</zip>
		</address>
		<ceo>Jerry Gilliland</ceo>
		<dateCreated>1988-10-25</dateCreated>
	</company>
	<company>
		<name>Mae Mutual Corporation</name>
		<address>
			<street>5737 Roundwood Lane</street>
			<city>Appleton</city>
			<state>Nebraska</state>
			<zip>ME20559</zip>
		</address>
		<ceo>Sherill Rayford</ceo>
		<dateCreated>1981-09-15</dateCreated>
	</company>
	<company>
		<name>Pc A.G</name>
		<address>
			<street>0628 Balshaw Street</street>
			<city>Pittsburgh</city>
			<state>Arkansas</state>
			<zip>OR01573</zip>
		</address>
		<ceo>Amiee Solis</ceo>
		<dateCreated>2012-05-30</dateCreated>
	</company>
	<company>
		<name>Mathematics Software GmbH</name>
		<address>
			<street>1776 Rough Lane</street>
			<city>Fort Wayne</city>
			<state>Massachusetts</state>
			<zip>HI71966</zip>
		</address>
		<ceo>Garrett Dickerson</ceo>
		<dateCreated>2022-11-17</dateCreated>
	</company>
	<company>
		<name>Ski Industries Pte. Ltd</name>
		<address>
			<street>2628 Unwick Circle</street>
			<city>Trenton</city>
			<state>Delaware</state>
			<zip>VT94732</zip>
		</address>
		<ceo>Pei Frederick</ceo>
		<dateCreated>2003-03-20</dateCreated>
	</company>
	<company>
		<name>Rides Software Ltd</name>
		<address>
			<street>4232 Warley Street</street>
			<city>Harlingen</city>
			<state>Massachusetts</state>
			<zip>NM74100</zip>
		</address>
		<ceo>Tomi Florence</ceo>
		<dateCreated>2019-07-08</dateCreated>
	</company>
	<company>
		<name>Relax S.A</name>
		<address>
			<street>8747 Rangemore</street>
			<city>Stockton</city>
			<state>Wisconsin</state>
			<zip>VT83769</zip>
		</address>
		<ceo>Anthony Pichardo</ceo>
		<dateCreated>1973-12-09</dateCreated>
	</company>
	<company>
		<name>Requests </name>
		<address>
			<street>9131 Searby Lane</street>
			<city>Macon</city>
			<state>Iowa</state>
			<zip>MO91097</zip>
		</address>
		<ceo>Carola Olivas</ceo>
		<dateCreated>1989-09-24</dateCreated>
	</company>
	<company>
		<name>Post International Inc</name>
		<address>
			<street>2290 Cinamon Street</street>
			<city>Utica</city>
			<state>Maine</state>
			<zip>DE15362</zip>
		</address>
		<ceo>Ngoc Nagel</ceo>
		<dateCreated>1996-02-14</dateCreated>
	</company>
	<company>
		<name>Read Holdings Inc</name>
		<address>
			<street>0523 Birchbrook</street>
			<city>Hemet</city>
			<state>Texas</state>
			<zip>TN70174</zip>
		</address>
		<ceo>Jeni Boisvert-Lara</ceo>
		<dateCreated>2002-02-28</dateCreated>
	</company>
	<company>
		<name>Prague Company</name>
		<address>
			<street>3273 Great</street>
			<city>Oceanside</city>
			<state>Arkansas</state>
			<zip>AK14991</zip>
		</address>
		<ceo>Ariel Dempsey</ceo>
		<dateCreated>1971-09-30</dateCreated>
	</company>
	<company>
		<name>Aspect Mutual </name>
		<address>
			<street>5377 McKean Road</street>
			<city>Boise</city>
			<state>Rhode Island</state>
			<zip>UT99066</zip>
		</address>
		<ceo>Flossie Hester</ceo>
		<dateCreated>2004-01-31</dateCreated>
	</company>
	<company>
		<name>Stocks Software Company</name>
		<address>
			<street>5495 Kenstford Road</street>
			<city>San Antonio</city>
			<state>Tennessee</state>
			<zip>LA67160</zip>
		</address>
		<ceo>Ahmad Ambrose</ceo>
		<dateCreated>2014-01-15</dateCreated>
	</company>
	<company>
		<name>Indicated Stores Corporation</name>
		<address>
			<street>4063 Cleworth Circle</street>
			<city>GreenBay</city>
			<state>Nebraska</state>
			<zip>OR99052</zip>
		</address>
		<ceo>Alica Wiese</ceo>
		<dateCreated>1997-06-16</dateCreated>
	</company>
	<company>
		<name>Remedies Ltd</name>
		<address>
			<street>8247 Crosshill</street>
			<city>Orem</city>
			<state>Florida</state>
			<zip>AR41015</zip>
		</address>
		<ceo>Selene Tidwell</ceo>
		<dateCreated>2022-10-12</dateCreated>
	</company>
	<company>
		<name>Reasonably B.V</name>
		<address>
			<street>3075 Mottram Road</street>
			<city>Oakland</city>
			<state>South Carolina</state>
			<zip>PA56722</zip>
		</address>
		<ceo>Dianne Mayes</ceo>
		<dateCreated>2016-11-13</dateCreated>
	</company>
	<company>
		<name>Ntsc Corp</name>
		<address>
			<street>1050 Davenport Circle</street>
			<city>Saint Paul</city>
			<state>Delaware</state>
			<zip>VT63860</zip>
		</address>
		<ceo>Marta Reeves</ceo>
		<dateCreated>1971-05-03</dateCreated>
	</company>
	<company>
		<name>Showtimes Holdings Corp</name>
		<address>
			<street>4732 Glynne Avenue</street>
			<city>Arvada</city>
			<state>North Dakota</state>
			<zip>CT17298</zip>
		</address>
		<ceo>Flor Oden</ceo>
		<dateCreated>1978-01-02</dateCreated>
	</company>
	<company>
		<name>Rangers Corp</name>
		<address>
			<street>6565 Higher Road</street>
			<city>Torrance</city>
			<state>West Virginia</state>
			<zip>KS21411</zip>
		</address>
		<ceo>Jaqueline Kyle</ceo>
		<dateCreated>1978-09-18</dateCreated>
	</company>
	<company>
		<name>Const Corporation</name>
		<address>
			<street>7997 Park</street>
			<city>Vero Beach</city>
			<state>Delaware</state>
			<zip>AZ10633</zip>
		</address>
		<ceo>Toi Yount</ceo>
		<dateCreated>1999-08-22</dateCreated>
	</company>
	<company>
		<name>Math Software B.V</name>
		<address>
			<street>6135 Wilmur</street>
			<city>Lowell</city>
			<state>Kentucky</state>
			<zip>IA02702</zip>
		</address>
		<ceo>Kristie Marvin</ceo>
		<dateCreated>1979-06-23</dateCreated>
	</company>
	<company>
		<name>Billing Industries SIA</name>
		<address>
			<street>4766 Netherfield Street</street>
			<city>Roseville</city>
			<state>Florida</state>
			<zip>GA25266</zip>
		</address>
		<ceo>Ardell Clemmons</ceo>
		<dateCreated>2010-10-20</dateCreated>
	</company>
	<company>
		<name>Uc Mutual B.V</name>
		<address>
			<street>1859 Orphanage Street</street>
			<city>Modesto</city>
			<state>Alabama</state>
			<zip>AR40959</zip>
		</address>
		<ceo>Jill Tillery</ceo>
		<dateCreated>2012-12-15</dateCreated>
	</company>
	<company>
		<name>Craps LLC</name>
		<address>
			<street>3227 Gunnery</street>
			<city>Springfield</city>
			<state>Texas</state>
			<zip>GA87508</zip>
		</address>
		<ceo>Alphonso Bussey-Ventura</ceo>
		<dateCreated>1983-03-24</dateCreated>
	</company>
	<company>
		<name>Owner Holdings B.V</name>
		<address>
			<street>2116 Back</street>
			<city>San Antonio</city>
			<state>Oklahoma</state>
			<zip>MI20909</zip>
		</address>
		<ceo>Vivienne Dew</ceo>
		<dateCreated>1991-05-24</dateCreated>
	</company>
	<company>
		<name>Talks A.G</name>
		<address>
			<street>2354 Rylands Road</street>
			<city>Montgomery</city>
			<state>Wisconsin</state>
			<zip>OH52140</zip>
		</address>
		<ceo>Edra Krieger</ceo>
		<dateCreated>2013-12-03</dateCreated>
	</company>
	<company>
		<name>Facilitate Software S.A</name>
		<address>
			<street>3668 Ludgate</street>
			<city>Irvine</city>
			<state>Missouri</state>
			<zip>ID47086</zip>
		</address>
		<ceo>Shad Christie</ceo>
		<dateCreated>1987-03-04</dateCreated>
	</company>
	<company>
		<name>Baking Holdings GmbH</name>
		<address>
			<street>6743 Bracken</street>
			<city>Hayward</city>
			<state>Michigan</state>
			<zip>MI04293</zip>
		</address>
		<ceo>Emmitt Keeton</ceo>
		<dateCreated>1985-08-15</dateCreated>
	</company>
	<company>
		<name>Nintendo B.V</name>
		<address>
			<street>3842 Godward Circle</street>
			<city>Hayward</city>
			<state>Nevada</state>
			<zip>TN22890</zip>
		</address>
		<ceo>Gertie Haas</ceo>
		<dateCreated>2023-09-10</dateCreated>
	</company>
	<company>
		<name>Leonard Inc</name>
		<address>
			<street>4441 Love</street>
			<city>Brownsville</city>
			<state>Indiana</state>
			<zip>PA51846</zip>
		</address>
		<ceo>Lindy Kincaid</ceo>
		<dateCreated>2015-06-27</dateCreated>
	</company>
	<company>
		<name>Rid Pte. Ltd</name>
		<address>
			<street>9709 Sandfield Road</street>
			<city>Bradenton</city>
			<state>Michigan</state>
			<zip>WA89319</zip>
		</address>
		<ceo>Carlita Mckay</ceo>
		<dateCreated>2012-01-24</dateCreated>
	</company>
	<company>
		<name>Knows Industries </name>
		<address>
			<street>8554 Shudehill Street</street>
			<city>Champaign</city>
			<state>Indiana</state>
			<zip>CO25149</zip>
		</address>
		<ceo>Mallie Schmitz</ceo>
		<dateCreated>2020-09-18</dateCreated>
	</company>
	<company>
		<name>Apparently S.A</name>
		<address>
			<street>6465 Isherwood Road</street>
			<city>Riverside</city>
			<state>Tennessee</state>
			<zip>OH58938</zip>
		</address>
		<ceo>Lesha Watkins</ceo>
		<dateCreated>1985-03-28</dateCreated>
	</company>
	<company>
		<name>Fellow International GmbH</name>
		<address>
			<street>8951 Anaconda Street</street>
			<city>Worcester</city>
			<state>Louisiana</state>
			<zip>TN45678</zip>
		</address>
		<ceo>Enriqueta Sanford</ceo>
		<dateCreated>1978-10-13</dateCreated>
	</company>
	<company>
		<name>Bestsellers Holdings </name>
		<address>
			<street>1844 Graham Road</street>
			<city>Utica</city>
			<state>Michigan</state>
			<zip>AZ89250</zip>
		</address>
		<ceo>Catrice Brinson</ceo>
		<dateCreated>1978-04-03</dateCreated>
	</company>
</ctRoot>
"""