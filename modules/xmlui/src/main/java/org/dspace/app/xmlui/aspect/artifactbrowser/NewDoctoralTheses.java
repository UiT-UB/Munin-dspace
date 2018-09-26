/*
 * NewDoctoralTheses.java
 *
 * **Version: $Revision: 3705 $
 *
 * **Date: $Date: 2009-04-11 17:02:24 +0000 (Sat, 11 Apr 2009) $
 *
 * Copyright (c) 2002, Hewlett-Packard Company and Massachusetts
 * Institute of Technology.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 * - Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * - Neither the name of the Hewlett-Packard Company nor the name of the
 * Massachusetts Institute of Technology nor the names of their
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
 * TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;

import java.util.Calendar;
import java.util.ArrayList;
import java.util.List;

import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.source.impl.validity.NOPValidity;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.app.xmlui.wing.element.Para;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.xml.sax.SAXException;

import org.dspace.content.Metadatum;
import org.dspace.content.Item;

import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

/**
 * KM: This component adds a box with newly submitted doctoral theses
 *
 * @author Karl Magnus Nilsen
 */
public class NewDoctoralTheses extends AbstractDSpaceTransformer //implements CacheableProcessingComponent
{
    /** Language Strings */
    
//     public static final Message T_dspace_home =
//         message("xmlui.general.dspace_home");
	
     private static final Message T_head = 
	 message("ub.xmlui.ArtifactBrowser.NewDoctoralTheses.head");

     private static final Message T_intro = 
	 message("ub.xmlui.ArtifactBrowser.NewDoctoralTheses.intro");

     private static final Message T_intro_noitems = 
	 message("ub.xmlui.ArtifactBrowser.NewDoctoralTheses.intro_noitems");

    
//     private static final Message T_para1 =
//         message("xmlui.ArtifactBrowser.FrontPageSearch.para1");
    
//     private static final Message T_go =
//         message("xmlui.general.go");
    
    
// To avoid caching: Comment out CacheableProcessingComponent interface and the getKey() and getValidity() methods

//     /**
//      * Generate the unique caching key.
//      * This key must be unique inside the space of this component.
//      */
//     public Serializable getKey() 
//     {
//        return "1";
//     }

//     /**
//      * Generate the cache validity object.
//      */
//     public SourceValidity getValidity() 
//     {
//         return NOPValidity.SHARED_INSTANCE;
//     }
    
    /**
     * Add a page title and trail links.
     */
//     public void addPageMeta(PageMeta pageMeta) throws SAXException,
//             WingException, UIException, SQLException, IOException,
//             AuthorizeException
//     {
//     	//pageMeta.addMetadata("title").addContent(T_dspace_home);
//     	pageMeta.addTrailLink(contextPath, T_dspace_home);
 
//     }
    


     public void addBody(Body body) throws SAXException, WingException,
             UIException, SQLException, IOException, AuthorizeException
     {
	 Division newTheses = body.addDivision("new-doctoral-theses");

	 List ni = getNewDoctoralTheses();
	 Item[] newItems = new Item[ni.size()];
	 newItems = (Item[]) ni.toArray(newItems);

	 newTheses.setHead(T_head);
	 
	 if(newItems.length == 0){
	     newTheses.addPara(T_intro_noitems);
	 }
	 else{
	     newTheses.addPara(T_intro);
	 }

//         List pooledList = WorkflowManager.getPooledTasks(context, currentUser);
//         WorkflowItem[] pooled = new WorkflowItem[pooledList.size()];
//         pooled = (WorkflowItem[]) pooledList.toArray(pooled);


	 //Print author name, title og date for upcoming presentation
	 for(int i=0; i<newItems.length; i++){
	     
	     Metadatum[] authors = newItems[i].getMetadata("dc", "contributor", "author", Item.ANY);
	     Metadatum[] titles = newItems[i].getMetadata("dc", "title", null, Item.ANY);
	     Metadatum[] dates = newItems[i].getMetadata("dc", "date", "issued", Item.ANY);

	     String itemUrl = ConfigurationManager.getProperty("dspace.url") + "/handle/" + newItems[i].getHandle();
	     
	     // FIXME: Maybe check if there are more than one author, title or date (it is not supposed to be more than one, I think)
	     //        (or if for some reason one of these fields are empty; that will cause an ArrayIndexOutOfBoundsException)
	     String tempAuthor = authors[0].value;
	     String title = titles[0].value;
	     String tempDate = dates[0].value;

	     // Some formatting of author and date
	     int comma = tempAuthor.indexOf(",");
	     String author = tempAuthor.substring(comma + 2) + " " + tempAuthor.substring(0, comma);
	     
	     //String year = "";
	     //String month = "";
	     //String day = "";

	     Para pHead = newTheses.addPara();


	     // This should be a mandatory field ..
	     if(tempDate != null){
		 
		 // Only year
		 if(tempDate.length() == 4){
		     pHead.addHighlight("bold").addContent(tempDate.substring(0, 4) + ":" + " ");
		 }
		 // Year and month
		 else if(tempDate.length() == 7){
		     
		     String month = tempDate.substring(5, 7);
		     Message T_month = message("ub.xmlui.dri2xhtml.METS-1.0.item-month-" + month);
		     pHead.addHighlight("bold").addContent(T_month);
		     pHead.addHighlight("bold").addContent(" " + tempDate.substring(0, 4) + ":" + " ");
		 }
		 // Full date
		 else{
		     pHead.addHighlight("bold").addContent(tempDate.substring(8) + " ");
		     String month = tempDate.substring(5, 7);
		     Message T_month = message("ub.xmlui.dri2xhtml.METS-1.0.item-month-" + month);
		     pHead.addHighlight("bold").addContent(T_month);
		     pHead.addHighlight("bold").addContent(" " + tempDate.substring(0, 4) + ":" + " ");
		 }
	     }

 	     pHead.addHighlight("bold").addContent(author);

	     Para pLink = newTheses.addPara();

	     pLink.addHighlight("italic").addXref(itemUrl, title);

	 }


	 //division.setHead(T_head);
     }


//         Division search = 
//         	body.addInteractiveDivision("front-page-search",contextPath+"/search",Division.METHOD_GET,"primary");
        
//         search.setHead(T_head);
        
//         search.addPara(T_para1);
        
//         Para fields = search.addPara();
//         fields.addText("query");
//         fields.addButton("submit").setValue(T_go);
//     }

    /**
     * Get all doctoral theses that has dc.date.issued today or in the future
     */
    
    private List getNewDoctoralTheses() throws SQLException {

	ArrayList newDoctoralItems = new ArrayList();

	TableRowIterator tri = queryDateIssued();
	if (tri != null){
	    try {
		while (tri.hasNext()){
		    TableRow tr = tri.next();
		    
		    //Hent ut item_id og text_value fra tr
		    String dcDateIssued = tr.getStringColumn("text_value");
		    int itemId = tr.getIntColumn("resource_id");

		    //Get item fra item_id
		    Item item = Item.find(context, itemId);

		    // Check if the item is published
		    if(item.getHandle() == null){
			continue;
		    }
		    
		    //Sjekk at dc.date.issued er senere enn dagens dato
		    //Hvis nei, break
		    //Hvis ja, fortsett
		    Metadatum[] dates = item.getMetadata("dc", "date", "issued", Item.ANY);
		    if(dates.length > 0 && dates[0].value.compareTo(getTodaysDate()) >= 0){

			//Sjekk at dc.type = Doctoral thesis/Doktorgradsavhandling
			//Hvis ja, legg i array som skal returneres
			//Hvis nei, fortsett
			Metadatum[] types = item.getMetadata("dc", "type", null, Item.ANY);
			for(int i=0; i<types.length; i++){
			    if(types[i].value.equals("Doctoral thesis") || types[i].value.equals("Doktorgradsavhandling")){
				// Add to list
				newDoctoralItems.add(0, item);
				break;
			    }
			}
		    }
		    // We have no more future doctoral presentations
		    else {
			break;
		    }
		}
	    }
	    
	    finally {
		tri.close();
	    }
	}

	return newDoctoralItems;
    }


    /** 
     * Get today's date and convert it to a string of the DSpace format (YYYY-MM-DD)
     */
    
    private String getTodaysDate(){
	
	Calendar rightNow = Calendar.getInstance();

	// Add a week (7*24*60*60*1000 = 604800000 ms)
	long nowMs = rightNow.getTimeInMillis();
	rightNow.setTimeInMillis(nowMs - 604800000);

	String dateString = String.format("%1$tY-%1$tm-%1$td", rightNow);

	//int year = rightNow.get(Calendar.YEAR);
	//int month = rightNow.get(Calendar.MONTH) + 1;
	//int day = rightNow.get(Calendar.DAY_OF_MONTH);
	
	return dateString;
    }

    /**
     * Get items sorted by dc.date.issued
     */
    
    private TableRowIterator queryDateIssued() throws SQLException {

        return DatabaseManager.queryTable(context, "metadatavalue",
                "SELECT resource_id, text_value FROM metadatavalue " +
		" WHERE metadata_field_id=15" +
                " ORDER BY text_value DESC");
    }
    
}