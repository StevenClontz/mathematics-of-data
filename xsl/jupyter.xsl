<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="section" select="'0.0'"/>
  <xsl:param name="includepreviews" select="'yes'"/>

  <!-- JSON Escaped Strings -->
  <!-- stolen from PreTeXt -->
  <xsl:template name="escape-json-string">
    <xsl:param name="text"/>
    <xsl:variable name="sans-backslash" select="str:replace($text,           '\',      '\\'     )"/>
    <xsl:variable name="sans-slash"     select="str:replace($sans-backslash, '/',      '\/'     )"/>
    <xsl:variable name="sans-quote"     select="str:replace($sans-slash,     '&#x22;', '\&#x22;')"/>
    <xsl:variable name="sans-tab"       select="str:replace($sans-quote,     '&#x09;', '\t'     )"/>
    <xsl:variable name="sans-newline"   select="str:replace($sans-tab,       '&#x0a;', '\n'     )"/>
    <xsl:variable name="sans-return"    select="str:replace($sans-newline,   '&#x0d;', '\r'     )"/>
    <xsl:variable name="sans-dollar"    select="str:replace($sans-return,    '$',      '\\$'    )"/><!-- added by clontz -->
    <xsl:value-of select="$sans-dollar" />
  </xsl:template>

  <!-- Basic Jupyter Cell -->
  <xsl:template name="jupyter-cell">
    <xsl:param name="source"/>
    <xsl:param name="editable"/>
    <xsl:param name="first-cell"/>
    <xsl:if test="not($first-cell)">,</xsl:if>
    {
     "cell_type": "markdown",
     "metadata": {
      "collapsed": false,
      "editable": <xsl:choose><xsl:when test="$editable"><xsl:value-of select="$editable"/></xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>
     },
    "source":
    <xsl:choose>
      <xsl:when test="$editable">
        ""
      </xsl:when>
      <xsl:otherwise>
        "&lt;div class=\"not-editable\" style=\"<xsl:call-template name="css-not-editable"/>\"&gt;<xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="$source"/></xsl:call-template>&lt;/div&gt;"
      </xsl:otherwise>
    </xsl:choose>
    }
  </xsl:template>

<!--  <xsl:template name="minimize">
    <xsl:param name="data"/>
    <xsl:value-of select="normalize-space($data)"/>
  </xsl:template>-->

  <!-- <xsl:template name="css"> TODO this seems to be broken in longer notebooks
    &lt;style&gt;
      .editable{<xsl:call-template name="css-editable"/>}
      .not-editable{<xsl:call-template name="css-not-editable"/>}
      .sidebyside{<xsl:call-template name="css-sidebyside"/>}
      .sidebyside > *{<xsl:call-template name="css-sidebyside-child"/>}
      .todo{<xsl:call-template name="css-todo"/>}
      caption{<xsl:call-template name="css-caption"/>}
      figcaption{<xsl:call-template name="css-figcaption"/>}
      .fillin{<xsl:call-template name="css-fillin"/>}
      .fn{<xsl:call-template name="css-fn"/>}
      .newcommands{<xsl:call-template name="css-newcommands"/>}
      tt{<xsl:call-template name="css-code"/>}
    &lt;/style&gt;
  </xsl:template>-->
  <xsl:template name="css"/><!-- So for now the template is dummied out; smaller templates below should be used instead. -->
  <xsl:template name="css-editable">margin:1em;color:#ccc;font-size:2em;text-align:center;</xsl:template>
  <xsl:template name="css-not-editable">background-color:#eef8ff;padding:1em;border-radius:10px;box-shadow:4px 4px 3px #ddd;margin:5px;</xsl:template>
  <xsl:template name="css-sidebyside">display:flex;justify-content:center;</xsl:template>
  <xsl:template name="css-sidebyside-child">display:flex;justify-content:center;</xsl:template>
  <xsl:template name="css-todo">color:#f00;font-weight:bold;</xsl:template>
  <xsl:template name="css-caption">caption-side:top;white-space: nowrap;color:rgba(0,0,0,.45)}</xsl:template>
  <xsl:template name="css-figcaption">padding-top:0.75em;padding-bottom:0.3em;color:rgba(0,0,0,.45)</xsl:template>
  <xsl:template name="css-fillin">display:inline-block;width:10em;margin-left:0.2em;margin-right:0.2em;height:1em;border-bottom:1px black solid;</xsl:template>
  <xsl:template name="css-fn">font-size:0.8em;color:rgba(0,0,0.45)</xsl:template>
  <xsl:template name="css-newcommands">display:none;</xsl:template>
  <xsl:template name="css-code">background-color:#f8f8f8;border:1px #888 solid;border-radius:2px;padding-left:0.2em;padding-right:0.2em;</xsl:template>

  <xsl:template name="newcommands">
    &lt;span class="newcommands" style="<xsl:call-template name="css-newcommands"/>"&gt;\(\newcommand{\amp}{&amp;}\)&lt;/span&gt;
  </xsl:template>

  <!-- Jupyter JSON object -->
  <xsl:template match="/">
<!--    <xsl:call-template name="minimize">
        <xsl:with-param name="data">-->
          <xsl:apply-templates select="section"/>
<!--        </xsl:with-param>
    </xsl:call-template>-->
  </xsl:template>
  <xsl:template match="section">
    {"nbformat": 4,"nbformat_minor": 0,"cells": [
      <xsl:call-template name="jupyter-cell">
        <xsl:with-param name="first-cell">true</xsl:with-param>
        <xsl:with-param name="source"><xsl:call-template name="css"/><xsl:call-template name="newcommands"/>&lt;h1&gt;<xsl:value-of select="$section"/>&#160;<xsl:value-of select="title"/>&lt;/h1&gt;&lt;div&gt;<xsl:apply-templates select="." mode="link"/>&lt;/div&gt;</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="//activity|//exploration"/>
      ]
      <xsl:choose>
      <xsl:when test="@jupyter-kernel = 'sage'">
 ,"metadata": {
  "kernelspec": {
   "display_name": "SageMath 9.1",
   "language": "sagemath",
   "metadata": {
    "cocalc": {
     "description": "Open-source mathematical software system",
     "priority": 10,
     "url": "https://www.sagemath.org/"
    }
   },
   "name": "sage-9.1"
  }
 }
      </xsl:when>
      <xsl:otherwise>
 ,"metadata": {
  "kernelspec": {
   "display_name": "Python 3 (system-wide)",
   "language": "python",
   "metadata": {
    "cocalc": {
     "description": "Python 3 programming language",
     "priority": 100,
     "url": "https://www.python.org/"
    }
   },
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.6.9"
  }
 }
      </xsl:otherwise>
      </xsl:choose>
    }
  </xsl:template>
  <xsl:template match="section" mode="url">
    <xml:text>https://stevenclontz.github.io/mathematics-of-data/html/<xsl:value-of select="./@xml:id"/>.html</xml:text>
  </xsl:template>
  <xsl:template match="section" mode="link">
    &lt;a href="<xsl:apply-templates select="." mode="url"/>"&gt;<xsl:apply-templates select="." mode="url"/>&lt;/a&gt;
  </xsl:template>
  <xsl:template match="section" mode="number"><xsl:value-of select="$section"/></xsl:template>

  <xsl:template match="subsection" mode="number"><xsl:apply-templates select="./ancestor::section" mode="number"/>.<xsl:number from="//section" level="any" count="subsection"/></xsl:template>
  <xsl:template match="subsection" mode="name">Subsection <xsl:apply-templates select="." mode="number"/></xsl:template>


  <!-- Supported PreTeXt elements -->

  <xsl:template match="exploration|activity">
    <xsl:if test="$includepreviews='yes' or local-name()='activity'">
      <xsl:call-template name="jupyter-cell">
        <xsl:with-param name="source">
          &lt;h3&gt;<xsl:apply-templates select="." mode="name"/>&lt;/h3&gt;
        </xsl:with-param>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="statement">
          <xsl:apply-templates select="statement"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(.//task)">
        <xsl:call-template name="jupyter-cell">
          <xsl:with-param name="editable">true</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <xsl:template match="exploration|activity" mode="number"><xsl:apply-templates select="./ancestor::section" mode="number"/>.<xsl:number from="//section" level="any" count="exploration|activity"/></xsl:template>
  <xsl:template match="exploration" mode="name">Preview Activity <xsl:apply-templates select="." mode="number"/></xsl:template>
  <xsl:template match="activity" mode="name">Activity <xsl:apply-templates select="." mode="number"/></xsl:template>

  <xsl:template match="statement|introduction">
    <xsl:apply-templates select="*"/>
  </xsl:template>
  <xsl:template match="task">
    <xsl:call-template name="jupyter-cell">
      <xsl:with-param name="source">
        &lt;span&gt;&lt;b&gt;<xsl:number format="a. "/>&lt;/b&gt;&lt;/span&gt;
        <xsl:apply-templates select="*[position()=1]" mode="markdown"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates select="*[position()>1]"/>
    <xsl:call-template name="jupyter-cell">
      <xsl:with-param name="editable">true</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="statement/*|introduction/*|task/*">
    <xsl:call-template name="jupyter-cell">
      <xsl:with-param name="source">
        <xsl:apply-templates select="." mode="markdown"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="sidebyside" mode="markdown">&lt;div class="sidebyside" style="<xsl:call-template name="css-sidebyside"/>"&gt;<xsl:apply-templates select="*" mode="markdown"/>&lt;/div&gt;</xsl:template>

  <xsl:template match="image" mode="markdown">&lt;div&gt;&lt;img src="<xsl:value-of select="normalize-spaces(@source)"/>.svg"/&gt;&lt;/div&gt;</xsl:template>

  <xsl:template match="figure" mode="markdown">&lt;div&gt;&lt;figure&gt;&lt;figcaption style="<xsl:call-template name="css-figcaption"/>"&gt;&lt;b&gt;<xsl:apply-templates select="normalize-spaces(.)" mode="name"/>.&lt;/b&gt; <xsl:apply-templates select="caption|title" mode="markdown"/>&lt;/figcaption&gt;<xsl:apply-templates select="image" mode="markdown"/>&lt;/figure&gt;&lt;/div&gt;</xsl:template>

  <xsl:template match="table" mode="markdown">&lt;div&gt;&lt;table&gt;&lt;caption style="<xsl:call-template name="css-caption"/>"&gt;&lt;b&gt;<xsl:apply-templates select="." mode="name"/>.&lt;/b&gt; <xsl:apply-templates select="caption|title" mode="markdown"/>&lt;/caption&gt;<xsl:apply-templates select="tabular/row" mode="markdown"/>&lt;/table&gt;&lt;/div&gt;</xsl:template>

  <xsl:template match="tabular" mode="markdown">&lt;div&gt;&lt;table&gt;<xsl:apply-templates select="row" mode="markdown"/>&lt;/table&gt;&lt;/div&gt;</xsl:template>

  <xsl:template match="listing" mode="markdown">&lt;div&gt;&lt;b&gt;<xsl:apply-templates select="." mode="name"/>.&lt;/b&gt;&lt;/div&gt;&lt;div&gt;<xsl:apply-templates select="*" mode="markdown"/>&lt;/div&gt;</xsl:template>

  <xsl:template match="row" mode="markdown">&lt;tr&gt;<xsl:apply-templates select="cell" mode="markdown"/>&lt;/tr&gt;</xsl:template>

  <xsl:template match="cell" mode="markdown">&lt;td&gt;<xsl:apply-templates select="text()|*" mode="markdown"/>&lt;/td&gt;</xsl:template>

  <xsl:template match="fn" mode="markdown"> &lt;span class="fn" style="<xsl:call-template name="css-fn"/>"&gt;(<xsl:apply-templates select="text()|*" mode="markdown"/>)&lt;/span&gt; </xsl:template>
  <xsl:template match="q" mode="markdown">"<xsl:apply-templates select="text()|*" mode="markdown"/>"</xsl:template>
  <xsl:template match="m" mode="markdown">\(<xsl:value-of select="normalize-space(text())"/>\)</xsl:template>
  <xsl:template match="me" mode="markdown">\[<xsl:value-of select="normalize-space(text())"/>\]</xsl:template>
  <xsl:template match="md" mode="markdown">\[\begin{align*}<xsl:apply-templates select="mrow" mode="markdown"/>\end{align*}\]</xsl:template>
  <xsl:template match="cd|input" mode="markdown">&lt;pre&gt;<xsl:value-of select="text()"/>&lt;/pre&gt;</xsl:template>
  <xsl:template match="program" mode="markdown"><xsl:apply-templates select="input" mode="markdown"/></xsl:template>
  <xsl:template match="c|kbd" mode="markdown">&lt;tt style="<xsl:call-template name="css-code"/>"&gt;<xsl:apply-templates select="text()|*" mode="markdown"/>&lt;/tt&gt;</xsl:template>
  <xsl:template match="mrow" mode="markdown"><xsl:value-of select="normalize-space(text())"/>\\</xsl:template>
  <xsl:template match="caption|title" mode="markdown"><xsl:apply-templates select="text()|*" mode="markdown"/></xsl:template>
  <xsl:template match="fillin" mode="markdown">&lt;span class="fillin" style="<xsl:call-template name="css-fillin"/>"&gt;&lt;/span&gt;</xsl:template>
  <xsl:template match="ol" mode="markdown">&lt;ol&gt;<xsl:apply-templates select="li" mode="markdown"/>&lt;/ol&gt;</xsl:template>
  <xsl:template match="ul" mode="markdown">&lt;ul&gt;<xsl:apply-templates select="li" mode="markdown"/>&lt;/ul&gt;</xsl:template>
  <xsl:template match="li" mode="markdown">&lt;li&gt;<xsl:apply-templates select="*|text()" mode="markdown"/>&lt;/li&gt;</xsl:template>
  <xsl:template match="p" mode="markdown">&lt;span&gt;<xsl:apply-templates select="text()|*" mode="markdown"/>&lt;/span&gt;</xsl:template>
  <xsl:template match="url" mode="markdown">&lt;a href="<xsl:value-of select="@href"/>"&gt;<xsl:apply-templates select="text()|*" mode="markdown"/>&lt;/a&gt;</xsl:template>


  <xsl:template match="table|figure|listing|definition|example" mode="number"><xsl:apply-templates select="./ancestor::section" mode="number"/>.<xsl:number from="//section" level="any" count="table|figure|listing|definition|example"/></xsl:template>
  <xsl:template match="table" mode="name">Table <xsl:apply-templates select="." mode="number"/></xsl:template>
  <xsl:template match="figure" mode="name">Figure <xsl:apply-templates select="." mode="number"/></xsl:template>
  <xsl:template match="definition" mode="name">Definition <xsl:apply-templates select="." mode="number"/></xsl:template>
  <xsl:template match="example" mode="name">Example <xsl:apply-templates select="." mode="number"/></xsl:template>
  <xsl:template match="listing" mode="name">Listing <xsl:apply-templates select="." mode="number"/></xsl:template>

  <xsl:template match="xref" mode="markdown">&lt;i&gt;<xsl:apply-templates select="//*[@xml:id=current()/@ref]" mode="name"/>&lt;/i&gt;</xsl:template>

<!-- https://stackoverflow.com/a/5044657/1607849 -->
  <xsl:template match="text()" mode="markdown"><xsl:value-of select="translate(normalize-space(concat('&#x7F;',.,'&#x7F;')),'&#x7F;','')"/></xsl:template>

</xsl:stylesheet>
