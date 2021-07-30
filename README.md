# NIST SP 800-53 comparison

This is an XSL transform to compare version 5 of 
NIST [Special Publication 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final) 
with its prior version. 

Input to the transform `800-53-compare.xsl`is the document `800-53-compare-github.xml` which 
identifies the several documents used. `odp-mapping.xml` identifies ODP changes between versions.
`800-53-compare.css` is companion CSS.
The output of the tgransform is an HTML5 document.

An XSLT 3.0 conformant toolset, such as [Saxon](https://saxonica.com/welcome/welcome.xml), is required.