/*************************************************************************
 * 
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 * 
 *************************************************************************/

package org.jboss.tools.deltacloud.client;

import java.util.List;

/**
 * @author Martyn Taylor
 */
public class Property extends IdAware {

	private static final long serialVersionUID = 1L;

	public static enum Kind {
		FIXED, RANGE, ENUM
	};

	public static enum Names {
		MEMORY, STORAGE, CPU, ARCHITECTURE
	}

	public static enum UNIT {
		MB {
		public boolean matches(String value) {
			return name().equals(value);
		}},
		GB{
			public boolean matches(String value) {
				return name().equals(value);
		}}, 
		LABEL{
			public boolean matches(String value) {
				return name().toLowerCase().equals(value);
		}}, 
		COUNT{
			public boolean matches(String value) {
				return name().toLowerCase().equals(value);
		}};
		
		public abstract boolean matches(String value);
	}
	
	public class Range {
		private String first;
		private String last;

		public Range(String first, String last) {
			this.first = first;
			this.last = last;
		}

		public String getFirst() {
			return first;
		}

		public String getLast() {
			return last;
		}
	}

	public Property() {
	}

	private String kind;

	private String unit;

	private String name;

	private String value;

	// For range
	private String first;
	private String last;

	// For enum
	private List<String> enums;

	public String getKind() {
		return kind;
	}

	public String getUnit() {
		return unit;
	}

	public String getName() {
		return name;
	}

	public String getValue() {
		return value;
	}

	public Range getRange() {
		return new Range(first, last);
	}

	public List<String> getEnums() {
		return enums;
	}

	public void setName(String name) {
		this.name = name;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public void setUnit(String unit) {
		this.unit = unit;
	}

	public void setKind(String kind) {
		this.kind = kind;
	}

	public void setRange(String first, String last) {
		this.first = first;
		this.last = last;
	}

	public void setEnums(List<String> enums) {
		this.enums = enums;
	}

	public String toString() {
		if (kind.equals("range")) {
			// return first += "-" + last + "(default:" + value + ")";
			return new StringBuilder()
					.append(first)
					.append('-').append(last)
					.append("(default: ").append(value).append(")")
					.toString();
		} else if (kind.equals("enum")) {
			String s = enums.get(0);
			for (int i = 1; i < enums.size(); ++i) {
				s += ", " + enums.get(i);
			}
			s += " (default:" + value + ")";
			return s;
		} else {
			// return value += " " + (unit.equals("label") ? "" : unit);
			StringBuilder builder = new StringBuilder();
			builder.append(value);
			if (!UNIT.LABEL.matches(unit)) {
				builder.append(' ').append(unit);
			}
			return builder.toString();
		}
	}

}
