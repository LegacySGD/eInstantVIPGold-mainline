<?xml version="1.0" encoding="UTF-8"?><xsl:stylesheet version="1.0" exclude-result-prefixes="java" extension-element-prefixes="my-ext" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:my-ext="ext1">
<xsl:import href="HTML-CCFR.xsl"/>
<xsl:output indent="no" method="xml" omit-xml-declaration="yes"/>
<xsl:template match="/">
<xsl:apply-templates select="*"/>
<xsl:apply-templates select="/output/root[position()=last()]" mode="last"/>
<br/>
</xsl:template>
<lxslt:component prefix="my-ext" functions="formatJson">
<lxslt:script lang="javascript">
					
					var debugFeed = [];
					var debugFlag = false;
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						var winningNums = getWinningNumbers(scenario);
						var outcomeNums = getOutcomeData(scenario, 0);
						var outcomePrizes = getOutcomeData(scenario, 1);
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');

						// Output winning numbers table.
						var r = [];
						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
 						r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="' + winningNums.length + '"&gt;');
 						r.push(getTranslationByName("winningNumbers", translations));
 						r.push('&lt;/td&gt;&lt;/tr&gt;');
 						r.push('&lt;tr&gt;');
 						for(var i = 0; i &lt; winningNums.length; ++i)
 						{
 							r.push('&lt;td class="tablebody"&gt;');
 							r.push(winningNums[i]);
 							r.push('&lt;/td&gt;');
 						}
 						r.push('&lt;/tr&gt;');
 						r.push('&lt;/table&gt;');

						// Output outcome numbers table.
 						r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
 						r.push('&lt;tr&gt;&lt;td class="tablehead" colspan="2"&gt;');
						r.push(getTranslationByName("yourNumbers", translations));
						r.push('&lt;/td&gt;&lt;/tr&gt;');
						r.push('&lt;tr&gt;');
 						r.push('&lt;tr&gt;');
 						r.push('&lt;td class="tablehead" width="50%"&gt;');
 						r.push(getTranslationByName("boardNumbers", translations));
 						r.push('&lt;/td&gt;');
 						r.push('&lt;td class="tablehead" width="50%"&gt;');
 						r.push(getTranslationByName("boardValues", translations));
						r.push('&lt;/td&gt;');
 						r.push('&lt;/tr&gt;');
						for(var i = 0; i &lt; outcomeNums.length; ++i)
						{
							r.push('&lt;tr&gt;');
							r.push('&lt;td class="tablebody" width="50%"&gt;');
 							if(checkMatch(winningNums, outcomeNums[i]))
 							{
 								r.push(getTranslationByName("youMatched", translations) + ': ');
 							}
 							r.push(translateOutcomeNumber(outcomeNums[i], translations));
 							r.push('&lt;/td&gt;');
 							r.push('&lt;td class="tablebody" width="50%"&gt;');
 							r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, outcomePrizes[i])]);
							r.push('&lt;/td&gt;');
 						r.push('&lt;/tr&gt;');
						}
						r.push('&lt;/table&gt;');
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('&lt;table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed"&gt;');
							for(var idx = 0; idx &lt; debugFeed.length; ++idx)
 						{
								if(debugFeed[idx] == "")
									continue;
								r.push('&lt;tr&gt;');
 							r.push('&lt;td class="tablebody"&gt;');
								r.push(debugFeed[idx]);
 							r.push('&lt;/td&gt;');
 						r.push('&lt;/tr&gt;');
							}
						r.push('&lt;/table&gt;');
						}
						return r.join('');
					}
					
					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeStructStrings = prizeStructures.split("|");
						
						
						for(var i = 0; i &lt; pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeStructStrings[i];
							}
						}
						
						return "";
					}

					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}
					
					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function getWinningNumbers(scenario)
					{
						var numsData = scenario.split("|")[0];
						return numsData.split(",");
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["8", "35", "4", "13", ...] or ["E", "E", "D", "G", ...]
					function getOutcomeData(scenario, index)
					{
						var outcomeData = scenario.split("|")[1];
						var outcomePairs = outcomeData.split(",");
						var result = [];
						for(var i = 0; i &lt; outcomePairs.length; ++i)
						{
							result.push(outcomePairs[i].split(":")[index]);
						}
						return result;
					}

					// Input: 'X', 'E', or number (e.g. '23')
					// Output: translated text or number.
					function translateOutcomeNumber(outcomeNum, translations)
					{
						if(outcomeNum == 'I')
						{
							return getTranslationByName("instantWin", translations);
						}
						else if(outcomeNum == 'X')
						{
							return getTranslationByName("instantDoubler", translations);
						}
						else if(outcomeNum == 'M')
						{
							return getTranslationByName("instantMultiplier", translations);
						}
						else
						{
							return outcomeNum;
						}
					}
					
					// Input: List of winning numbers and the number to check
					// Output: true is number is contained within winning numbers or false if not
					function checkMatch(winningNums, boardNum)
					{
						for(var i = 0; i &lt; winningNums.length; ++i)
						{
							if(winningNums[i] == boardNum || boardNum == "I" || boardNum == "X" || boardNum == "M")
							{
								return true;
							}
						}
						
						return false;
					}
					
					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{			
						for(var i = 0; i &lt; prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}
						
					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}
					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index &lt; translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							if(childNode.getAttribute("key") == keyName)
							{
								return childNode.getAttribute("value");
							}
							index += 2;
						}
					}			
					
				</lxslt:script>
</lxslt:component>
<xsl:template match="root" mode="last">
<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWager']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
<tr>
<td valign="top" class="subheader">
<xsl:value-of select="//translation/phrase[@key='totalWins']/@value"/>
<xsl:value-of select="': '"/>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</td>
</tr>
</table>
</xsl:template>
<xsl:template match="//Outcome">
<xsl:if test="OutcomeDetail/Stage = 'Scenario'">
<xsl:call-template name="Scenario.Detail"/>
</xsl:if>
</xsl:template>
<xsl:template name="Scenario.Detail">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
<tr>
<td class="tablebold" background="">
<xsl:value-of select="//translation/phrase[@key='transactionId']/@value"/>
<xsl:value-of select="': '"/>
<xsl:value-of select="OutcomeDetail/RngTxnId"/>
</td>
</tr>
</table>
<xsl:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())"/>
<xsl:variable name="translations" select="lxslt:nodeset(//translation)"/>
<xsl:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)"/>
<xsl:variable name="prizeTable" select="lxslt:nodeset(//lottery)"/>
<xsl:variable name="convertedPrizeValues">
<xsl:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
</xsl:variable>
<xsl:variable name="prizeNames">
<xsl:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
</xsl:variable>
<xsl:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes"/>
</xsl:template>
<xsl:template match="prize" mode="PrizeValue">
<xsl:text>|</xsl:text>
<xsl:call-template name="Utils.ApplyConversionByLocale">
<xsl:with-param name="multi" select="/output/denom/percredit"/>
<xsl:with-param name="value" select="text()"/>
<xsl:with-param name="code" select="/output/denom/currencycode"/>
<xsl:with-param name="locale" select="//translation/@language"/>
</xsl:call-template>
</xsl:template>
<xsl:template match="description" mode="PrizeDescriptions">
<xsl:text>,</xsl:text>
<xsl:value-of select="text()"/>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>
