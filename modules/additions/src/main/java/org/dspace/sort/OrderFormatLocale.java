package org.dspace.sort;
/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */


import org.dspace.text.filter.LowerCaseAndTrim;
import org.dspace.text.filter.TextFilter;
import org.dspace.browse.LocaleOrderingFilter;
import org.dspace.sort.AbstractTextFilterOFD;


/**
 * Locale ordering delegate implementation
 * 
 * @author Svein Bjerken
 */
public class OrderFormatLocale extends AbstractTextFilterOFD
{
	{
		filters = new TextFilter[] { 
									 new LowerCaseAndTrim(),
									 new LocaleOrderingFilter()};
	}
}
