/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.vocabulary;

import org.apache.xpath.XPathAPI;
import org.dspace.core.ConfigurationManager;
import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * This class represents a single controlled vocabulary node
 * It also contains references to its child nodes
 *
 * @author Kevin Van de Velde (kevin at atmire dot com)
 */
public class ControlledVocabulary {
    private String id;
    private String label;
    private String value;
	//KMS: Add english value
	private String valueEng;
	//KME
    private List<ControlledVocabulary> childNodes;

	//KMS: Add English value parameter
    //public ControlledVocabulary(String id, String label, String value, List<ControlledVocabulary> childNodes) {
    public ControlledVocabulary(String id, String label, String value, String valueEng, List<ControlledVocabulary> childNodes) {
	//KME
        this.id = id;
        this.label = label;
        this.value = value;
		//KMS: Add english value
		this.valueEng = valueEng;
		//KME
        this.childNodes = childNodes;
    }

    /**
     * Load the vocabulary with the given filename, if no vocabulary is found null is returned
     * The vocabulary file will need to located in the [dspace.dir]/config/controlled-vocabulary directory.
     *
     * @param fileName the name of the vocabulary file.
     * @return a controlled vocabulary object
     * @throws IOException Should something go wrong with reading the file
     * @throws SAXException Error during xml parsing
     * @throws ParserConfigurationException Error during xml parsing
     * @throws TransformerException Error during xml parsing
     * TODO: add some caching !
     */
    public static ControlledVocabulary loadVocabulary(String fileName) throws IOException, SAXException, ParserConfigurationException, TransformerException {
        StringBuilder filePath = new StringBuilder();
        filePath.append(ConfigurationManager.getProperty("dspace.dir")).append(File.separatorChar).append("config").append(File.separatorChar).append("controlled-vocabularies").append(File.separator).append(fileName).append(".xml");

        File controlledVocFile = new File(filePath.toString());
        if(controlledVocFile.exists()){
            DocumentBuilder builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            Document document = builder.parse(controlledVocFile);
			//KMS: Add extra parameter for English value
            //return loadVocabularyNode(XPathAPI.selectSingleNode(document, "node"), "");
            return loadVocabularyNode(XPathAPI.selectSingleNode(document, "node"), "", "");
			//KME
        }else{
            return null;
		   }

    }

    /**
     * Loads a single node & all its child nodes recursively
     * @param node The current node that we need to parse
     * @param initialValue the value of parent node
     * @param initialValueEng the English value of parent node
     * @return a vocabulary node with all its children
     * @throws TransformerException should something go wrong with loading the xml
     */
	//KMS: Add extra parameter for English value
    //private static ControlledVocabulary loadVocabularyNode(Node node, String initialValue) throws TransformerException {
    private static ControlledVocabulary loadVocabularyNode(Node node, String initialValue, String initialValueEng) throws TransformerException {
	//KME
        Node idNode = node.getAttributes().getNamedItem("id");
        String id = null;
        if(idNode != null){
            id = idNode.getNodeValue();
        }
        Node labelNode = node.getAttributes().getNamedItem("label");
        String label = null;
        if(labelNode != null){
            label = labelNode.getNodeValue();
        }
		//KMS: Add English label
        Node labelEngNode = node.getAttributes().getNamedItem("labeleng");
        String labelEng = null;
        if(labelEngNode != null){
            labelEng = labelEngNode.getNodeValue();
        }
		//KME 
		//KMS: Add English value
        String value;
		String valueEng;
        if(0 < initialValue.length()){
            value = initialValue + "::" + label;
			valueEng = initialValueEng + "::" + labelEng;
        }else{
            value = label;
			valueEng = labelEng;
        }
		//KME
        NodeList subNodes = XPathAPI.selectNodeList(node, "isComposedBy/node");

        List<ControlledVocabulary> subVocabularies = new ArrayList<ControlledVocabulary>(subNodes.getLength());
        for(int i = 0; i < subNodes.getLength(); i++){
			//KMS: Add English value
            //subVocabularies.add(loadVocabularyNode(subNodes.item(i), value));
            subVocabularies.add(loadVocabularyNode(subNodes.item(i), value, valueEng));
			//KME
        }
        
		//KMS: Add English value
        //return new ControlledVocabulary(id, label, value, subVocabularies);
        return new ControlledVocabulary(id, label, value, valueEng, subVocabularies);
		//KME
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
    }

    public List<ControlledVocabulary> getChildNodes() {
        return childNodes;
    }

    public void setChildNodes(List<ControlledVocabulary> childNodes) {
        this.childNodes = childNodes;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

	//KMS: Set and get English values
    public String getValueEng() {
        return valueEng;
    }

    public void setValueEng(String valueEng) {
        this.valueEng = valueEng;
    }
	//KME
}
