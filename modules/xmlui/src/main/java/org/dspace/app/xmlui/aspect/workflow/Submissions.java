/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.workflow;

import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.*;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.*;
import org.dspace.content.Item;
import org.dspace.eperson.EPerson;
import org.dspace.workflow.WorkflowItem;
import org.dspace.workflow.WorkflowManager;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Arrays;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;


/**
 * @author Scott Phillips
 */
public class Submissions extends AbstractDSpaceTransformer
{
	/** General Language Strings */
    protected static final Message T_title =
        message("xmlui.Submission.Submissions.title");
    protected static final Message T_dspace_home =
        message("xmlui.general.dspace_home");
    protected static final Message T_trail =
        message("xmlui.Submission.Submissions.trail");
    protected static final Message T_head =
        message("xmlui.Submission.Submissions.head");
    protected static final Message T_untitled =
        message("xmlui.Submission.Submissions.untitled");
    protected static final Message T_email =
        message("xmlui.Submission.Submissions.email");

    // used by the workflow section
    protected static final Message T_w_head1 =
        message("xmlui.Submission.Submissions.workflow_head1");
    protected static final Message T_w_info1 =
        message("xmlui.Submission.Submissions.workflow_info1");
    protected static final Message T_w_head2 =
        message("xmlui.Submission.Submissions.workflow_head2");
    protected static final Message T_w_column1 =
        message("xmlui.Submission.Submissions.workflow_column1");
    protected static final Message T_w_column2 =
        message("xmlui.Submission.Submissions.workflow_column2");
    protected static final Message T_w_column3 =
        message("xmlui.Submission.Submissions.workflow_column3");
    protected static final Message T_w_column4 =
        message("xmlui.Submission.Submissions.workflow_column4");
    protected static final Message T_w_column5 =
        message("xmlui.Submission.Submissions.workflow_column5");
    protected static final Message T_w_submit_return =
        message("xmlui.Submission.Submissions.workflow_submit_return");
    protected static final Message T_w_info2 =
        message("xmlui.Submission.Submissions.workflow_info2");
    protected static final Message T_w_head3 =
        message("xmlui.Submission.Submissions.workflow_head3");
    protected static final Message T_w_submit_take =
        message("xmlui.Submission.Submissions.workflow_submit_take");
    protected static final Message T_w_info3 =
        message("xmlui.Submission.Submissions.workflow_info3");
    //KMS: Extra columns
    protected static final Message T_w_column_author = message("ub.xmlui.Submission.Submissions.workflow_author");
	protected static final Message T_w_column_description = message("ub.xmlui.Submission.Submissions.workflow_description");
	protected static final Message T_w_column_dateissued = message("ub.xmlui.Submission.Submissions.workflow_dateissued");
	protected static final Message T_w_column_type = message("ub.xmlui.Submission.Submissions.workflow_type");
    //KME

	// Used in the in progress section
    protected static final Message T_p_head1 =
        message("xmlui.Submission.Submissions.progress_head1");
    protected static final Message T_p_info1 =
        message("xmlui.Submission.Submissions.progress_info1");
    protected static final Message T_p_column1 =
        message("xmlui.Submission.Submissions.progress_column1");
    protected static final Message T_p_column2 =
        message("xmlui.Submission.Submissions.progress_column2");
    protected static final Message T_p_column3 =
        message("xmlui.Submission.Submissions.progress_column3");

    // The workflow status messages
    protected static final Message T_status_0 =
        message("xmlui.Submission.Submissions.status_0");
    protected static final Message T_status_1 =
        message("xmlui.Submission.Submissions.status_1");
    protected static final Message T_status_2 =
        message("xmlui.Submission.Submissions.status_2");
    protected static final Message T_status_3 =
        message("xmlui.Submission.Submissions.status_3");
    protected static final Message T_status_4 =
        message("xmlui.Submission.Submissions.status_4");
    protected static final Message T_status_5 =
        message("xmlui.Submission.Submissions.status_5");
    protected static final Message T_status_6 =
        message("xmlui.Submission.Submissions.status_6");
    protected static final Message T_status_7 =
        message("xmlui.Submission.Submissions.status_7");
    protected static final Message T_status_unknown =
        message("xmlui.Submission.Submissions.status_unknown");


    @Override
    public void addPageMeta(PageMeta pageMeta) throws SAXException,
	WingException, UIException, SQLException, IOException,
	AuthorizeException
	{
		pageMeta.addMetadata("title").addContent(T_title);

		pageMeta.addTrailLink(contextPath + "/",T_dspace_home);
		pageMeta.addTrailLink(contextPath + "/submissions",T_trail);
	}

    @Override
    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException
    {

        Division div = body.addInteractiveDivision("submissions", contextPath+"/submissions", Division.METHOD_POST,"primary");
        div.setHead(T_head);

	//KMS: Changed order of elements on submissions page
        this.addWorkflowTasks(div);
//        this.addUnfinishedSubmissions(div);
	this.addUnfinishedSubmissions(div);
        this.addSubmissionsInWorkflow(div);
//        this.addPreviousSubmissions(div);
	this.addPreviousSubmissions(div);
	//KME

    }


    /**
     * If the user has any workflow tasks, either assigned to them or in an
     * available pool of tasks, then build two tables listing each of these queues.
     *
     * If the user doesn't have any workflows then don't do anything.
     *
     * @param division The division to add the two queues too.
     */
    private void addWorkflowTasks(Division division) throws SQLException, WingException
    {
		//KMS: Get request
		Request request = ObjectModelHelper.getRequest(objectModel);
		String sortBy = request.getParameter("sortby");
		//KME


    	@SuppressWarnings("unchecked") // This cast is correct
    	List<WorkflowItem> ownedItems = WorkflowManager.getOwnedTasks(context, context
                .getCurrentUser());
    	@SuppressWarnings("unchecked") // This cast is correct.
    	List<WorkflowItem> pooledItems = WorkflowManager.getPooledTasks(context, context
                .getCurrentUser());

    	if (!(ownedItems.size() > 0 || pooledItems.size() > 0))
    		// No tasks, so don't show the table.
        {
            return;
        }

		//KMS: Sort owned and pooled 
		WorkflowItem[] ownedArray = ownedItems.toArray(new WorkflowItem[ownedItems.size()]);
		WorkflowItem[] pooledArray = pooledItems.toArray(new WorkflowItem[pooledItems.size()]);

		// If we want another default sort than the current
		if(sortBy == null){

		}
		else if(sortBy.equals("title")){
	        String[] elementsPooled = {"title"};
    	    String[] qualifiersPooled = {null};
       	 	ownedArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) ownedItems.toArray(ownedArray), elementsPooled, qualifiersPooled, "asc");
        	pooledArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) pooledItems.toArray(pooledArray), elementsPooled, qualifiersPooled, "asc");
		}
		else if(sortBy.equals("author")){
	        String[] elementsPooled = {"contributor"};
    	    String[] qualifiersPooled = {"author"};
       	 	ownedArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) ownedItems.toArray(ownedArray), elementsPooled, qualifiersPooled, "asc");
        	pooledArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) pooledItems.toArray(pooledArray), elementsPooled, qualifiersPooled, "asc");
		}
		else if(sortBy.equals("description")){
	        String[] elementsPooled = {"description"};
    	    String[] qualifiersPooled = {null};
       	 	ownedArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) ownedItems.toArray(ownedArray), elementsPooled, qualifiersPooled, "asc");
        	pooledArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) pooledItems.toArray(pooledArray), elementsPooled, qualifiersPooled, "asc");
		}
		else if(sortBy.equals("date")){
	        String[] elementsPooled = {"date"};
    	    String[] qualifiersPooled = {"issued"};
       	 	ownedArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) ownedItems.toArray(ownedArray), elementsPooled, qualifiersPooled, "desc");
        	pooledArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) pooledItems.toArray(pooledArray), elementsPooled, qualifiersPooled, "desc");
		}
		else if(sortBy.equals("type")){
	        String[] elementsPooled = {"type"};
    	    String[] qualifiersPooled = {null};
       	 	ownedArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) ownedItems.toArray(ownedArray), elementsPooled, qualifiersPooled, "asc");
        	pooledArray = WorkflowItem.sortWorkflowItems((WorkflowItem[]) pooledItems.toArray(pooledArray), elementsPooled, qualifiersPooled, "asc");
		}
		// Default sort if sortBy is set to something unknown
		else {

		}

		// Convert back to List
		ownedItems = Arrays.asList(ownedArray);
		pooledItems = Arrays.asList(pooledArray);
		
		//KME

    	Division workflow = division.addDivision("workflow-tasks");

	workflow.setHead(T_w_head1);
    	workflow.addPara(T_w_info1);
    	
    	// Tasks you own
	//KMS: More columns
    	//Table table = workflow.addTable("workflow-tasks",ownedItems.size() + 2,5);
    	Table table = workflow.addTable("workflow-tasks",ownedItems.size() + 2,7);
        table.setHead(T_w_head2);
        Row header = table.addRow(Row.ROLE_HEADER);
        header.addCellContent(T_w_column1);
        //header.addCellContent(T_w_column2);
        header.addCell().addXref("?sortby=title", T_w_column3);
	header.addCell().addXref("?sortby=author", T_w_column_author);
	header.addCell().addXref("?sortby=description", T_w_column_description);
	header.addCell().addXref("?sortby=date", T_w_column_dateissued);
	header.addCell().addXref("?sortby=type", T_w_column_type);
        header.addCellContent(T_w_column4);
        //header.addCellContent(T_w_column5);
	//KME

        if (ownedItems.size() > 0)
        {
        	for (WorkflowItem owned : ownedItems)
        	{
        		int workflowItemID = owned.getID();
        		String collectionUrl = contextPath + "/handle/" + owned.getCollection().getHandle();
        		String ownedWorkflowItemUrl = contextPath + "/handle/" + owned.getCollection().getHandle() + "/workflow?workflowID=" + workflowItemID;
			//KMS: getDC() --> getMetadata()
			Metadatum[] titles = owned.getItem().getMetadata("dc", "title", null, Item.ANY);
			//KME
        		String collectionName = owned.getCollection().getMetadata("name");
        		EPerson submitter = owned.getSubmitter();
        		String submitterName = submitter.getFullName();
        		String submitterEmail = submitter.getEmail();

			//KMS: Get authors, description, date issued and type
			Metadatum[] authors = owned.getItem().getMetadata("dc", "contributor", "author", Item.ANY);
			Metadatum[] descriptions = owned.getItem().getMetadata("dc", "description", null, Item.ANY);
			Metadatum[] dateissueds = owned.getItem().getMetadata("dc", "date", "issued", Item.ANY);
			Metadatum[] types = owned.getItem().getMetadata("dc", "type", null, Item.ANY);
			//KME

        		Message state = getWorkflowStateMessage(owned);

        		Row row = table.addRow();

        		CheckBox remove = row.addCell().addCheckBox("workflowID");
	        	remove.setLabel("selected");
	        	remove.addOption(workflowItemID);

        		// The task description
			//KMS: Remove task description
	        	//row.addCell().addXref(ownedWorkflowItemUrl, state);
			//KME

        		// The item description
        		if (titles != null && titles.length > 0)
        		{
        			String displayTitle = titles[0].value;
        			if (displayTitle.length() > 50)
                    {
                        displayTitle = displayTitle.substring(0, 50) + " ...";
                    }
        			row.addCell().addXref(ownedWorkflowItemUrl, displayTitle);
        		}
        		else
                {
                    row.addCell().addXref(ownedWorkflowItemUrl, T_untitled);
                }

			//KMS: Add authors, descriptions, dateissued, type, remove links, etc.
			// The item authors
			String displayAuthors = "unknown";
			for(Metadatum author : authors){
			    
			    if(!displayAuthors.equals("unknown")){
				displayAuthors = displayAuthors + "; ";
			    }
			    else {
				displayAuthors = "";
			    }
			    
			    displayAuthors = displayAuthors + author.value;
			}

			row.addCell().addContent(displayAuthors);

			// The item descriptions 
			String displayDescriptions = "";
			for(Metadatum description : descriptions){

				// Find URLs and shorten them
				String[] descStrings = description.value.split(" ");
				String tempDesc = "";
				for(String tempStr : descStrings){
					if(tempStr.length() > 30 && (tempStr.startsWith("http") || tempStr.startsWith("href=http"))){
						tempDesc += tempStr.substring(0,30) + "... ";
					}
					else {
						tempDesc += tempStr + " ";
					}
				}
			    
			    if(!displayDescriptions.equals("")){
				displayDescriptions = displayDescriptions + "; ";
			    }
			    else {
				displayDescriptions = "";
			    }
			    
			    displayDescriptions = displayDescriptions + tempDesc;
			}

			row.addCell().addContent(displayDescriptions);

			// The item date.issued 
			String displayDateissues = "";
			for(Metadatum dateissued : dateissueds){
			    
			    if(!displayDateissues.equals("")){
				displayDateissues = displayDateissues + "; ";
			    }
			    else {
				displayDateissues = "";
			    }
			    
			    displayDateissues = displayDateissues + dateissued.value;
			}

			row.addCell().addContent(displayDateissues);

			// The item types 
			String displayTypes = "";
			for(Metadatum type : types){
			    
			    if(!displayTypes.equals("")){
				displayTypes = displayTypes + "; ";
			    }
			    else {
				displayTypes = "";
			    }
			    
			    displayTypes = displayTypes + type.value;
			}

			row.addCell().addContent(displayTypes);

        		// Submitted too
        		//row.addCell().addXref(collectionUrl, collectionName);
        		row.addCell().addContent(collectionName);

        		// Submitted by
	        	//Cell cell = row.addCell();
	        	//cell.addContent(T_email);
	        	//cell.addXref("mailto:"+submitterEmail,submitterName);
				//cell.addContent(submitterName);
			//KME
        	}

        	Row row = table.addRow();
 	    	row.addCell(0,5).addButton("submit_return_tasks").setValue(T_w_submit_return);
 	    	
        }
        else
        {
        	Row row = table.addRow();
        	row.addCell(0,5).addHighlight("italic").addContent(T_w_info2);
        }
			




        // Tasks in the pool
	//KMS: Edit columns
        //table = workflow.addTable("workflow-tasks",pooledItems.size()+2,5);
        table = workflow.addTable("workflow-tasks",pooledItems.size()+2,7);
        table.setHead(T_w_head3);

        header = table.addRow(Row.ROLE_HEADER);
        header.addCellContent(T_w_column1);
        //header.addCellContent(T_w_column2);
        header.addCell().addXref("?sortby=title", T_w_column3);
	header.addCell().addXref("?sortby=author", T_w_column_author);
	header.addCell().addXref("?sortby=description", T_w_column_description);
	header.addCell().addXref("?sortby=date", T_w_column_dateissued);
	header.addCell().addXref("?sortby=type", T_w_column_type);
        header.addCellContent(T_w_column4);
        //header.addCellContent(T_w_column5);
	//KME
	
        if (pooledItems.size() > 0)
        {

        	for (WorkflowItem pooled : pooledItems)
        	{
        		int workflowItemID = pooled.getID();
        		String collectionUrl = contextPath + "/handle/" + pooled.getCollection().getHandle();
        		String pooledItemUrl = contextPath + "/handle/" + pooled.getCollection().getHandle() + "/workflow?workflowID=" + workflowItemID;
			Metadatum[] titles = pooled.getItem().getDC("title", null, Item.ANY);
        		String collectionName = pooled.getCollection().getMetadata("name");
        		EPerson submitter = pooled.getSubmitter();
        		String submitterName = submitter.getFullName();
        		String submitterEmail = submitter.getEmail();

			//KMS: Get authors
			Metadatum[] authors = pooled.getItem().getDC("contributor", "author", Item.ANY);
			Metadatum[] descriptions = pooled.getItem().getMetadata("dc", "description", null, Item.ANY);
			Metadatum[] dateissueds = pooled.getItem().getMetadata("dc", "date", "issued", Item.ANY);
			Metadatum[] types = pooled.getItem().getMetadata("dc", "type", null, Item.ANY);
			//KME

        		Message state = getWorkflowStateMessage(pooled);


        		Row row = table.addRow();

        		CheckBox remove = row.addCell().addCheckBox("workflowID");
	        	remove.setLabel("selected");
	        	remove.addOption(workflowItemID);

        		// The task description
			//KMS: Remove task description
	        	//row.addCell().addXref(pooledItemUrl, state);
			//KME

        		// The item description
        		if (titles != null && titles.length > 0)
        		{
        			String displayTitle = titles[0].value;
        			if (displayTitle.length() > 50)
                    {
                        displayTitle = displayTitle.substring(0, 50) + " ...";
                    }

        			row.addCell().addXref(pooledItemUrl, displayTitle);
        		}
        		else
                {
                    row.addCell().addXref(pooledItemUrl, T_untitled);
                }

			//KMS: Add authors, remove links, etc.
			// The item authors
			String displayAuthors = "unknown";
			for(Metadatum author : authors){
			    
			    if(!displayAuthors.equals("unknown")){
				displayAuthors = displayAuthors + "; ";
			    }
			    else {
				displayAuthors = "";
			    }
			    
			    displayAuthors = displayAuthors + author.value;
			}

			row.addCell().addContent(displayAuthors);

			// The item descriptions 
			String displayDescriptions = "";
			for(Metadatum description : descriptions){

				// Find URLs and shorten them
				String[] descStrings = description.value.split(" ");
				String tempDesc = "";
				for(String tempStr : descStrings){
					if(tempStr.length() > 30 && (tempStr.startsWith("http") || tempStr.startsWith("href=http"))){
						tempDesc += tempStr.substring(0,30) + "... ";
					}
					else {
						tempDesc += tempStr + " ";
					}
				}
			    
			    if(!displayDescriptions.equals("")){
				displayDescriptions = displayDescriptions + "; ";
			    }
			    else {
				displayDescriptions = "";
			    }
			    
			    displayDescriptions = displayDescriptions + tempDesc;
			}

			row.addCell().addContent(displayDescriptions);

			// The item date.issued 
			String displayDateissues = "";
			for(Metadatum dateissued : dateissueds){
			    
			    if(!displayDateissues.equals("")){
				displayDateissues = displayDateissues + "; ";
			    }
			    else {
				displayDateissues = "";
			    }
			    
			    displayDateissues = displayDateissues + dateissued.value;
			}

			row.addCell().addContent(displayDateissues);

			// The item types 
			String displayTypes = "";
			for(Metadatum type : types){
			    
			    if(!displayTypes.equals("")){
				displayTypes = displayTypes + "; ";
			    }
			    else {
				displayTypes = "";
			    }
			    
			    displayTypes = displayTypes + type.value;
			}

			row.addCell().addContent(displayTypes);

        		// Submitted too
        		//row.addCell().addXref(collectionUrl, collectionName);
			row.addCell().addContent(collectionName);

        		// Submitted by
        		//Cell cell = row.addCell();
	        	//cell.addContent(T_email);
	        	//cell.addXref("mailto:"+submitterEmail,submitterName);
			//cell.addContent(submitterName);
			//KME
        	}
        	Row row = table.addRow();
 	    	row.addCell(0,5).addButton("submit_take_tasks").setValue(T_w_submit_take);
        }
        else
        {
        	Row row = table.addRow();
        	row.addCell(0,5).addHighlight("italic").addContent(T_w_info3);
        }
    }

    /**
     * There are two options, the user has some unfinished submissions
     * or the user does not.
     *
     * If the user does not, then we just display a simple paragraph
     * explaining that the user may submit new items to dspace.
     *
     * If the user does have unfinisshed submissions then a table is
     * presented listing all the unfinished submissions that this user has.
     *
     */
    private void addUnfinishedSubmissions(Division division) throws SQLException, WingException
    {
        division.addInteractiveDivision("unfinished-submisions", contextPath+"/submit", Division.METHOD_POST);

    }

    /**
     * This section lists all the submissions that this user has submitted which are currently under review.
     *
     * If the user has none, this nothing is displayed.
     */
    private void addSubmissionsInWorkflow(Division division) throws SQLException, WingException
    {
    	WorkflowItem[] inprogressItems = WorkflowItem.findByEPerson(context,context.getCurrentUser());

    	// If there is nothing in progress then don't add anything.
    	if (!(inprogressItems.length > 0))
        {
            return;
        }

    	Division inprogress = division.addDivision("submissions-inprogress");
    	inprogress.setHead(T_p_head1);
    	inprogress.addPara(T_p_info1);


    	Table table = inprogress.addTable("submissions-inprogress",inprogressItems.length+1,3);
        Row header = table.addRow(Row.ROLE_HEADER);
        header.addCellContent(T_p_column1);
        header.addCellContent(T_p_column2);
        header.addCellContent(T_p_column3);


        for (WorkflowItem workflowItem : inprogressItems)
        {
		Metadatum[] titles = workflowItem.getItem().getDC("title", null, Item.ANY);
        	String collectionName = workflowItem.getCollection().getMetadata("name");
        	Message state = getWorkflowStateMessage(workflowItem);


        	Row row = table.addRow();

        	// Add the title column
        	if (titles.length > 0)
        	{
        		String displayTitle = titles[0].value;
    			if (displayTitle.length() > 50)
                {
                    displayTitle = displayTitle.substring(0, 50) + " ...";
                }
        		row.addCellContent(displayTitle);
        	}
        	else
            {
                row.addCellContent(T_untitled);
            }

        	// Collection name column
        	row.addCellContent(collectionName);

        	// Status column
        	row.addCellContent(state);
        }
    }





    /**
     * Determine the correct message that describes this workflow item's state.
     *
     * FIXME: change to return type of message;
     */
    private Message getWorkflowStateMessage(WorkflowItem workflowItem)
    {
		switch (workflowItem.getState())
		{
			case WorkflowManager.WFSTATE_SUBMIT:
				return T_status_0;
			case WorkflowManager.WFSTATE_STEP1POOL:
				return T_status_1;
    		case WorkflowManager.WFSTATE_STEP1:
    			return T_status_2;
    		case WorkflowManager.WFSTATE_STEP2POOL:
    			return T_status_3;
    		case WorkflowManager.WFSTATE_STEP2:
    			return T_status_4;
    		case WorkflowManager.WFSTATE_STEP3POOL:
    			return T_status_5;
    		case WorkflowManager.WFSTATE_STEP3:
    			return T_status_6;
    		case WorkflowManager.WFSTATE_ARCHIVE:
    			return T_status_7;
   			default:
   				return T_status_unknown;
		}
    }

    /**
     * Show the user's completed submissions.
     *
     * If the user has no completed submissions, display nothing.
     * If 'displayAll' is true, then display all user's archived submissions.
     * Otherwise, default to only displaying 50 archived submissions.
     *
     * @param division div to put archived submissions in
     */
    private void addPreviousSubmissions(Division division)
            throws SQLException,WingException
    {
        division.addDivision("completed-submissions");

    }
}
