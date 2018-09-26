/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.workflow;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.InProgressSubmission;
import org.dspace.content.Item;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

import org.dspace.content.Metadatum;

/**
 * Class representing an item going through the workflow process in DSpace
 * 
 * @author Robert Tansley
 * @version $Revision$
 */
public class WorkflowItem implements InProgressSubmission
{
    /** log4j category */
    private static Logger log = Logger.getLogger(WorkflowItem.class);

    /** The item this workflow object pertains to */
    private Item item;

    /** Our context */
    private Context ourContext;

    /** The table row corresponding to this workflow item */
    private TableRow wfRow;

    /** The collection the item is being submitted to */
    private Collection collection;

    /** EPerson owning the current state */
    private EPerson owner;

    /**
     * Construct a workspace item corresponding to the given database row
     * 
     * @param context
     *            the context this object exists in
     * @param row
     *            the database row
     */
    WorkflowItem(Context context, TableRow row) throws SQLException
    {
        ourContext = context;
        wfRow = row;

        item = Item.find(context, wfRow.getIntColumn("item_id"));
        collection = Collection.find(context, wfRow
                .getIntColumn("collection_id"));

        if (wfRow.isColumnNull("owner"))
        {
            owner = null;
        }
        else
        {
            owner = EPerson.find(context, wfRow.getIntColumn("owner"));
        }

        // Cache ourselves
        context.cache(this, row.getIntColumn("workflow_id"));
    }

    /**
     * Get a workflow item from the database. The item, collection and submitter
     * are loaded into memory.
     * 
     * @param context
     *            DSpace context object
     * @param id
     *            ID of the workspace item
     * 
     * @return the workflow item, or null if the ID is invalid.
     */
    public static WorkflowItem find(Context context, int id)
            throws SQLException
    {
        // First check the cache
        WorkflowItem fromCache = (WorkflowItem) context.fromCache(
                WorkflowItem.class, id);

		// KMS: Workaround for AuthorizeException on take task during workflow (https://jira.duraspace.org/browse/DS-2920)
		fromCache = null;
		// KME

        if (fromCache != null)
        {
            return fromCache;
        }

        TableRow row = DatabaseManager.find(context, "workflowitem", id);

        if (row == null)
        {
            if (log.isDebugEnabled())
            {
                log.debug(LogManager.getHeader(context, "find_workflow_item",
                        "not_found,workflow_id=" + id));
            }

            return null;
        }
        else
        {
            if (log.isDebugEnabled())
            {
                log.debug(LogManager.getHeader(context, "find_workflow_item",
                        "workflow_id=" + id));
            }

            return new WorkflowItem(context, row);
        }
    }

    /**
     * return all workflowitems
     * 
     * @param c  active context
     * @return WorkflowItem [] of all workflows in system
     */
    public static WorkflowItem[] findAll(Context c) throws SQLException
    {
        List<WorkflowItem> wfItems = new ArrayList<WorkflowItem>();
        TableRowIterator tri = DatabaseManager.queryTable(c, "workflowitem",
                "SELECT * FROM workflowitem");

        try
        {
            // make a list of workflow items
            while (tri.hasNext())
            {
                TableRow row = tri.next();
                WorkflowItem wi = new WorkflowItem(c, row);
                wfItems.add(wi);
            }
        }
        finally
        {
            if (tri != null)
            {
                tri.close();
            }
        }

        return wfItems.toArray(new WorkflowItem[wfItems.size()]);
    }

    /**
     * Get all workflow items that were original submissions by a particular
     * e-person. These are ordered by workflow ID, since this should likely keep
     * them in the order in which they were created.
     * 
     * @param context
     *            the context object
     * @param ep
     *            the eperson
     * 
     * @return the corresponding workflow items
     */
    public static WorkflowItem[] findByEPerson(Context context, EPerson ep)
            throws SQLException
    {
        List<WorkflowItem> wfItems = new ArrayList<WorkflowItem>();

        TableRowIterator tri = DatabaseManager.queryTable(context, "workflowitem",
                "SELECT workflowitem.* FROM workflowitem, item WHERE " +
                "workflowitem.item_id=item.item_id AND " +
                "item.submitter_id= ? " + 
                "ORDER BY workflowitem.workflow_id",
                ep.getID());

        try
        {
            while (tri.hasNext())
            {
                TableRow row = tri.next();

                // Check the cache
                WorkflowItem wi = (WorkflowItem) context.fromCache(
                        WorkflowItem.class, row.getIntColumn("workflow_id"));

                if (wi == null)
                {
                    wi = new WorkflowItem(context, row);
                }

                wfItems.add(wi);
            }
        }
        finally
        {
            if (tri != null)
            {
                tri.close();
            }
        }

        return wfItems.toArray(new WorkflowItem[wfItems.size()]);
    }

    /**
     * Get all workflow items for a particular collection.
     * 
     * @param context
     *            the context object
     * @param c
     *            the collection
     * 
     * @return array of the corresponding workflow items
     */
    public static WorkflowItem[] findByCollection(Context context, Collection c)
            throws SQLException
    {
        List<WorkflowItem> wsItems = new ArrayList<WorkflowItem>();

        TableRowIterator tri = DatabaseManager.queryTable(context, "workflowitem",
                "SELECT workflowitem.* FROM workflowitem WHERE " +
                "workflowitem.collection_id= ? ",
                c.getID());

        try
        {
            while (tri.hasNext())
            {
                TableRow row = tri.next();

                // Check the cache
                WorkflowItem wi = (WorkflowItem) context.fromCache(
                        WorkflowItem.class, row.getIntColumn("workflow_id"));

                // not in cache? turn row into workflowitem
                if (wi == null)
                {
                    wi = new WorkflowItem(context, row);
                }

                wsItems.add(wi);
            }
        }
        finally
        {
            if (tri != null)
            {
                tri.close();
            }
        }

        return wsItems.toArray(new WorkflowItem[wsItems.size()]);
    }


    /**
     * Check to see if a particular item is currently under Workflow.
     * If so, its WorkflowItem is returned.  If not, null is returned
     *
     * @param context
     *            the context object
     * @param i
     *            the item
     *
     * @return workflow item corresponding to the item, or null
     */
    public static WorkflowItem findByItem(Context context, Item i)
            throws SQLException
    {
        // Look for the unique workflowitem entry where 'item_id' references this item
        TableRow row =  DatabaseManager.findByUnique(context, "workflowitem", "item_id", i.getID());

        if (row == null)
        {
            return null;
        }
        else
        {
            return new WorkflowItem(context, row);
        }
    }

    /**
     * Get the internal ID of this workflow item
     * 
     * @return the internal identifier
     */
    public int getID()
    {
        return wfRow.getIntColumn("workflow_id");
    }

    /**
     * get owner of WorkflowItem
     * 
     * @return EPerson owner
     */
    public EPerson getOwner()
    {
        return owner;
    }

    /**
     * set owner of WorkflowItem
     * 
     * @param ep
     *            owner
     */
    public void setOwner(EPerson ep)
    {
        owner = ep;

        if (ep == null)
        {
            wfRow.setColumnNull("owner");
        }
        else
        {
            wfRow.setColumn("owner", ep.getID());
        }
    }

    /**
     * Get state of WorkflowItem
     * 
     * @return state
     */
    public int getState()
    {
        return wfRow.getIntColumn("state");
    }

    /**
     * Set state of WorkflowItem
     * 
     * @param newstate
     *            new state (from <code>WorkflowManager</code>)
     */
    public void setState(int newstate)
    {
        wfRow.setColumn("state", newstate);
		//KM: DEBUG
		System.out.println("state: " + newstate);
    }

    /**
     * Update the workflow item, including the unarchived item.
     */
    public void update() throws SQLException, AuthorizeException
    {
        // FIXME check auth
        log.info(LogManager.getHeader(ourContext, "update_workflow_item",
                "workflow_item_id=" + getID()));

        // Update the item
        item.update();

        // Update ourselves
        DatabaseManager.update(ourContext, wfRow);
    }

    /**
     * delete the WorkflowItem, retaining the Item
     */
    public void deleteWrapper() throws SQLException, IOException,
            AuthorizeException
    {
        // Remove from cache
        ourContext.removeCached(this, getID());

        // delete any pending tasks
        WorkflowManager.deleteTasks(ourContext, this);

        // FIXME - auth?
        DatabaseManager.delete(ourContext, wfRow);
    }

    // InProgressSubmission methods
    public Item getItem()
    {
        return item;
    }

    public Collection getCollection()
    {
        return collection;
    }

    public EPerson getSubmitter() throws SQLException
    {
        return item.getSubmitter();
    }

    public boolean hasMultipleFiles()
    {
        return wfRow.getBooleanColumn("multiple_files");
    }

    public void setMultipleFiles(boolean b)
    {
        wfRow.setColumn("multiple_files", b);
    }

    public boolean hasMultipleTitles()
    {
        return wfRow.getBooleanColumn("multiple_titles");
    }

    public void setMultipleTitles(boolean b)
    {
        wfRow.setColumn("multiple_titles", b);
    }

    public boolean isPublishedBefore()
    {
        return wfRow.getBooleanColumn("published_before");
    }

    public void setPublishedBefore(boolean b)
    {
        wfRow.setColumn("published_before", b);
    }


    //KMS: Sorting methods for lists of workflow items
    /**
     * Sort items (used in the method sortWorkflowItems()
     *
     * @param wfItems
     *            the array containing the current workflow items
     * @param index
     *            the index of the wfItems array that currently being compared with the rest of the elements
     * @param elements
     *            array of dc elements in the order they will be used in the sort
     * @param qualifiers
     *            array of dc qualifiers in the order they will be used in the sort (elements and qualifiers must of course have the same size)
     * @param count
     *            the index of the element that is being compared with the element with index 'param index'
     * @param elementsIndex
     *            the current index of the elements (and qualifiers) array
     * @param order
     *            sorting orde: asc or desc
     * @return the index to use in the sort
     */

    private static int sortItems(WorkflowItem[] wfItems, int index, String[] elements, String[] qualifiers, int count, int elementsIndex, String order){

    String metadataValue1 = "unknown";
    String metadataValue2 = "unknown";

    Metadatum[] metadata1 = wfItems[index].getItem().getMetadata("dc", elements[elementsIndex], qualifiers[elementsIndex], Item.ANY);
    Metadatum[] metadata2 = wfItems[count].getItem().getMetadata("dc", elements[elementsIndex], qualifiers[elementsIndex], Item.ANY);

    if(metadata1.length > 0){
        metadataValue1 = metadata1[0].value;
    }

    if(metadata2.length > 0){
        metadataValue2 = metadata2[0].value;
    }

    int compareVal = metadataValue1.compareToIgnoreCase(metadataValue2);

    // Negate the compareVal if the order is descending
    if(order.equals("desc")){
        compareVal = 0 - compareVal;
    }

    // Compare the values
    if(compareVal > 0){
        return count;
    }

    // If the values are equal, compare the next values

    else if(metadataValue1.compareToIgnoreCase(metadataValue2) == 0){

        // Compare the values
        if (elementsIndex+1 < elements.length){
        return sortItems(wfItems, index, elements, qualifiers, count, elementsIndex+1, order);
        }
        else{
        return index;
        }
    }
    else{
        return index;
    }
	}

    /**
     * Sort items in Workflow Item lists
     *
     * Only use mandatory fields in the sort, or else something bad happens..
     *
     * @param wfItems
     *             the array containing the current workflow items
     * @param e
     *             array of dc elements in the order they will be used in the sort
     * @param q
     *             array of dc qualifiers in the order they will be used in the sort (elements and qualifiers must of course have the same size)
     * @param order
     *             Indicate sorting order: asc or desc
     * @return the sorted array
     */

    public static WorkflowItem[] sortWorkflowItems(WorkflowItem[] wf, String[] e, String[] q, String order){
    String[] elements = e;
    String[] qualifiers = q;

    WorkflowItem tempItem = null;

    int tempIndex = 0;
    for (int i=0; i<wf.length; i++){
        tempIndex = i;
        for (int j=i+1; j<wf.length; j++){
        // Last parameter is 0 because we start sorting by the first fields in the elements and qualifier arrays
        tempIndex = sortItems(wf, tempIndex, elements, qualifiers, j, 0, order);
        }
        if (tempIndex != i){
        tempItem = wf[tempIndex];
        wf[tempIndex] = wf[i];
        wf[i] = tempItem;
        }
    }

    return wf;
    }
    //KME
}
