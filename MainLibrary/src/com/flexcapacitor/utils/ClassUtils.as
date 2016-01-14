



package com.flexcapacitor.utils {
	
	import com.flexcapacitor.model.AccessorMetaData;
	import com.flexcapacitor.model.MetaData;
	import com.flexcapacitor.model.StyleMetaData;
	
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	
	import mx.core.IFlexModuleFactory;
	import mx.core.UIComponent;
	import mx.styles.IStyleClient;
	import mx.styles.IStyleManager2;
	import mx.styles.StyleManager;
	import mx.utils.ArrayUtil;
	import mx.utils.DescribeTypeCache;
	import mx.utils.DescribeTypeCacheRecord;
	import mx.utils.NameUtil;
	import mx.utils.ObjectUtil;

	/**
	 * Helper class for class utilities.
	 * 
	 * TODO: 
	 * We could cache the value of many of these calls including getPropertyNames, getPropertyMetaData, etc.
	 * */
	public class ClassUtils {


		public function ClassUtils() {

		}
		
		public static const STYLE:String = "Style";
		public static const EVENT:String = "Event";
		
		/**
		 * Get unqualified class name of the target object
		 * */
		public static function getClassName(element:Object):String {
			var name:String = NameUtil.getUnqualifiedClassName(element);
			return name;
		}
		
		/**
		 * Get unqualified class name of the document of the target object
		 * returns null if element is not a UIComponent
		 * */
		public static function getDocumentName(element:Object):String {
			var name:String;
			if (element is UIComponent) {
				name = NameUtil.getUnqualifiedClassName(UIComponent(element).document);
			}
			return name;
		}
		
		/**
		 * Get parent document name
		 * 
		 * @return null if target is not a UIComponent
		 */
		public static function getParentDocumentName(target:Object):String {
			var className:String;
			if (target is UIComponent) {
				className = getClassName(target.parentDocument);
			}
			return className;
		}
		
		/**
		 * Get unqualified class name of the target object. <br/>
		 * 
		 * If target has the id of myImage and include class name is true then the result is
		 * "Image.myImage". If delimiter is "_" then the result is "Image_myImage". 
		 * If includeClassName is false then the result is, "myImage". 
		 * */
		public static function getClassNameOrID(element:Object, includeClassName:Boolean = false, delimiter:String = "."):String {
			var name:String = NameUtil.getUnqualifiedClassName(element);
			var id:String = element && "id" in element ? element.id : null;
			
			return !id ? name : includeClassName ? name + delimiter + id : id;
		}
		
		/**
		 * Get the type of the value passed in
		 * */
		public static function getValueType(value:*):String {
			var type:String = getQualifiedClassName(value);
			
			if (type=="int") {
				if (typeof value=="number") {
					type = "Number";
				}
			}
			
			return type;
		}
		
		/**
		 * Get package of the target object
		 * */
		public static function getPackageName(element:Object):String {
			var name:String = flash.utils.getQualifiedClassName(element);
			if (name && name.indexOf("::")) {
				name = name.split("::")[0];
			}
			
			return name;
		}

		/**
		 * Get super class name of the target object
		 * */
		public static function getSuperClassName(element:Object):String {
			var name:String = flash.utils.getQualifiedSuperclassName(element);
			if (name && name.indexOf("::")) {
				name = name.split("::")[name.split("::").length-1]; // i'm sure theres a better way to do this
			}
			
			return name;
		}

		/**
		 * Get the package of the super class name of the target
		 * */
		public static function getSuperClassPackage(element:Object):String {
			var name:String = flash.utils.getQualifiedSuperclassName(element);
			if (name && name.indexOf("::")) {
				name = name.split("::")[0];
			}
			
			return name;
		}

		/**
		 * Gets the ID of the target object
		 * returns null if no ID is specified or target is not a UIComponent
		 * */
		public static function getIdentifier(element:Object):String {
			var id:String;

			if (element && element.hasOwnProperty("id")) {
				id = element.id;
			}
			return id;
		}

		/**
		 * Get name of target object or null if not available
		 * */
		public static function getName(element:Object):String {
			var name:String;

			if (element.hasOwnProperty("name") && element.name) {
				name = element.name;
			}

			return name;
		}

		/**
		 * Get qualified class name of the target object
		 * */
		public static function getQualifiedClassName(element:Object):String {
			var name:String = flash.utils.getQualifiedClassName(element);
			return name;
		}
		
		/**
		 * Get the class name and package. 
		 * 
		 * @returns an Array with className at index 0 and the package name as index 1 
		 */
		public static function getClassNameAndPackage(target:Object):Array {
			var className:String;
			var classPath:String;
			
			className = getClassName(target);
			classPath = getPackageName(target);
			
			return [className, classPath];
		}
		
		
		/**
		 *  Returns <code>true</code> if the object reference specified
		 *  is a simple data type. The simple data types include the following:
		 *  <ul>
		 *    <li><code>String</code></li>
		 *    <li><code>Number</code></li>
		 *    <li><code>uint</code></li>
		 *    <li><code>int</code></li>
		 *    <li><code>Boolean</code></li>
		 *    <li><code>Date</code></li>
		 *    <li><code>Array</code></li>
		 *  </ul>
		 *
		 *  @param value Object inspected.
		 *
		 *  @return <code>true</code> if the object specified
		 *  is one of the types above; <code>false</code> otherwise.
		 *  */
		public static function isSimple(value:*):Boolean {
			return ObjectUtil.isSimple(value);
		}
		
		/**
		 * Get metadata from an object by finding members by their type.
		 * It loops through all the properties on the object and if 
		 * it is of the type you passed in then it returns the metadata on it.
<pre>
var object:XMLList = ClassUtils.getMemberDataByType(myButton, mx.styles.CSSStyleDeclaration);

trace(object);

// finds the "myButton.styleDeclaration" since it is of type CSSStyleDeclaration

&lt;accessor name="styleDeclaration" access="readwrite" type="mx.styles::CSSStyleDeclaration" declaredBy="mx.core::UIComponent">
  &lt;metadata name="Inspectable">
    &lt;arg key="environment" value="none"/>
  &lt;/metadata>
&lt;/accessor>
</pre>
		 * */
		public static function getMemberDataByType(object:Object, type:Object):Object {
			if (type==null) return null;
			var className:String = type is String ? String(type) : getQualifiedClassName(type);
			var xml:XML = describeType(object);
			var xmlItem:XMLList = xml.*.(attribute("type")==className);
			return xmlItem;
		}
		
		/**
		 * Get metadata from an object by it's name.
		 * 
<pre>
var object:XMLList = ClassUtils.getMemberDataByName(myButton, "width");
trace(object);

// finds metadata for "myButton.width" 

&lt;accessor name="width" access="readwrite" type="String" declaredBy="mx.core::UIComponent">
&lt;/accessor>
</pre>
		 * */
		public static function getMemberDataByName(object:Object, propertyName:String, caseSensitive:Boolean = false):Object {
			if (propertyName==null) return null;
			var xml:XML = describeType(object);
			var xmlItem:XMLList;
			var lowerCaseProperty:String = propertyName.toLowerCase();
			
			if (caseSensitive) {
				xmlItem = xml.*.(attribute("name")==propertyName);
			}
			else {
				xmlItem = xml.*.(attribute("name").toString().toLowerCase()==lowerCaseProperty);
			}
			return xmlItem;
		}

		/**
		 * Checks if the source object is the same type as the target object. 
<pre>
var sameType:Boolean = isSameClassType(myButton, yourButton);
trace(sameType); // true

var sameType:Boolean = isSameClassType(myButton, myCheckbox);
trace(sameType); // false

</pre>
		 * */
		public static function isSameClassType(source:Object, target:Object):Boolean {
			if (source==null && target!=null) {
				return false;
			}
			if (target==null && source!=null) {
				return false;
			}
			
			if (flash.utils.getQualifiedClassName(source) == flash.utils.getQualifiedClassName(target)) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Gets the ID of the object or name or if name is not available gets the class name or null. 
		 * 
<pre>
var name:String = getIdentifierOrName(myButton);
trace(name); // Button

myButton.name = "Button100"
var name:String = getIdentifierOrName(myButton);
trace(name); // "Button100"
 
myButton.id = "myButton";
var name:String = getIdentifierOrName(myButton);
trace(name); // "mySuperButton" 

</pre>
		 * @param name if id is not available then return name
		 * @param className if id and name are not available get class name
		 * 
		 * returns id or name or class name or null if none are found
		 * */
		public static function getIdentifierOrName(element:Object, name:Boolean = true, className:Boolean = true):String {

			if (element && "id" in element && element.id) {
				return element.id;
			}
			else if (element && name && "name" in element && element.name) {
				return element.name;
			}
			else if (element && className) {
				return getClassName(element);
			}
			
			return null;
		}
		
		/**
		 * Gets the ID of the object or name or if name is not available gets the class name or null. 
		 * 
		 * returns id or name or class name or null if none are found
		 * */
		public static function getIdentifierNameOrClass(element:Object):String {
			
			return getIdentifierOrName(element, true, true);
		}
		
		/**
		 * Get DescribeTypeCacheRecord.typeDescription for the given class. 
		 * Can take string, instance or class.
		 * 
		 * If class can't be found returns null 
		 * */
		public static function getDescribeType(object:Object):XML {
			var describedTypeRecord:mx.utils.DescribeTypeCacheRecord = mx.utils.DescribeTypeCache.describeType(object);
			
			if (describedTypeRecord) {
				return describedTypeRecord.typeDescription;
			}
			
			return null
		}
		
		
		/**
		 * Returns an array the properties for the given object including super class properties. <br/><br/>
		 * 
		 * Properties including accessors and variables are included.<br/><br/>
		 * 
		 * For example, if you give it a Spark Button class it gets all the
		 * properties for it and all the properties on the super classes.<br/><br/>
		 * 
		 * Usage:<br/>
 <pre>
 var allProperties:Array = getObjectPropertyNames(myButton);
 </pre>
		 * 
		 * @param object The object to inspect. Either string, object or class.
		 * @param sort Sorts the properties in the array
		 * 
		 * @see #getPropertiesMetaData()
		 * */
		public static function getPropertyNames(object:Object, sort:Boolean = true):Array {
			var describedTypeRecord:DescribeTypeCacheRecord = mx.utils.DescribeTypeCache.describeType(object);
			var typeDescription:* = describedTypeRecord.typeDescription;
			var hasFactory:Boolean = typeDescription.factory.length()>0;
			var factory:XMLList = typeDescription.factory;
			var itemsLength:int;
			var itemsList:XMLList;
			var propertyName:String;
			var properties:Array = [];
			
			itemsList = hasFactory ? factory.variable + factory.accessor : typeDescription.variable + typeDescription.accessor;
			itemsLength = itemsList.length();
			
			for (var i:int;i<itemsLength;i++) {
				var item:XML = XML(itemsList[i]);
				propertyName = item.@name;
				properties.push(propertyName);
			}
			
			if (describedTypeRecord.typeName=="Object" && itemsLength==0) {
				for (propertyName in object) {
					properties.push(propertyName);
				}
			}
			
			if (sort) properties.sort();
			
			return properties;
		}
		
		
		/**
		 * Returns true if the object has the property specified. <br/><br/>
		 * 
		 * If useFlashAPI is true then uses Flash internal methods
<pre> 
"property" in object and object.hasOwnProperty(propertyName);
</pre>
		 * <br/>
		 * 
		 * Otherwise it uses describeType. It includes accessors and variables and checks 
		 * super classes.<br/><br/>
		 * 
		 * For example:<br/>
<pre>
var hasProperty:Boolean = ClassUtils.hasProperty(myButton, "label"); // true
var hasProperty:Boolean = ClassUtils.hasProperty(myButton, "spagetti"); // false
var hasProperty:Boolean = ClassUtils.hasProperty(myButton, "width"); // true
</pre>
		 * 
		 * @param object The object to check property for
		 * @param propertyName Name of property to check for
		 * @param useFlashAPI Uses Flash internal methods
		 * 
		 * @see #hasStyle()
		 * */
		public static function hasProperty(object:Object, propertyName:String, useFlashAPI:Boolean = false):Boolean {
			if (object==null || object=="" || propertyName==null || propertyName=="") return false;
			
			if (useFlashAPI) {
				var found:Boolean;
				found = propertyName in object;
				
				if (!found) {
					found = object.hasOwnProperty(propertyName);
				}
				
				return found;
			}
			
			var properties:Array = getPropertyNames(object);
			
			if (properties.indexOf(propertyName)!=-1) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if the object has the style specified. <br/><br/>
		 * 
		 * If useOtherMethod is true then we check inherited and noninherited objects
		 * to see if they have the style listed. Not sure if this is correct.
 <pre> 
 var hasStyle:Boolean = style in styleClient.inheritingStyles || styleName in styleClient.nonInheritingStyles;
 </pre>
		 * <br/>
		 * 
		 * Otherwise it uses describeType. We check not only the object but the super classes.<br/><br/>
		 * 
		 * For example:<br/>
 <pre>
 var hasStyle:Boolean = ClassUtils.hasStyle(myButton, "color"); // true
 var hasStyle:Boolean = ClassUtils.hasStyle(myButton, "spagetti"); // false
 </pre>
		 * 
		 * @param object The object to check style exists on
		 * @param styleName Name of style to check for
		 * @param useOtherMethod Uses Flash internal methods
		 * 
		 * @see #isStyleDefined()
		 * */
		public static function hasStyle(object:Object, styleName:String, useOtherMethod:Boolean = false):Boolean {
			var styleClient:IStyleClient = object ? object as IStyleClient : null;
			if (styleClient==null || styleClient=="" || styleName==null || styleName=="") return false;
			var found:Boolean;
			
			// not sure if this is a valid way to tell if an object has a style
			if (useOtherMethod) {
				if (styleName in styleClient.inheritingStyles) {
					found = true;
				}
				else if (styleName in styleClient.nonInheritingStyles) {
					found = true;
				}
			}
			
			if (useOtherMethod) {
				return found;
			}
			
			var styles:Array = getStyleNames(styleClient);
			
			if (styles.indexOf(styleName)!=-1) {
				return true;
			}
			
			return false;
		}
		
		/**
		 * Returns true if the object has the style defined somewhere in the style lookup.<br/><br/>
		 * 
		 * For example:<br/>
 <pre>
 var hasStyle:Boolean = ClassUtils.isStyleDefined(myButton, "color"); // true
 var hasStyle:Boolean = ClassUtils.isStyleDefined(myButton, "spagetti"); // false
 </pre>
		 * 
		 * @param object The object to check style exists on
		 * @param styleName Name of style to check for
		 * 
		 * @see StyleManager.isValidStyleValue()
		 * @see #hasStyle()
		 * */
		public static function isStyleDefined(object:Object, styleName:String):Boolean {
			var styleManager:IStyleManager2;
			var styleClient:IStyleClient = object ? object as IStyleClient : null;
			
			if (styleClient==null || styleClient=="" || styleName==null || styleName=="") return false;
			
			//if (object is IFlexModuleFactory) {
				styleManager = StyleManager.getStyleManager(object as IFlexModuleFactory);
			//}
			
			return styleManager.isValidStyleValue(styleClient.getStyle(styleName));
			
		}
		
		/**
		 * Gets the correct case of an objects property. For example, 
		 * "percentwidth" returns "percentWidth".
		 * 
		 * If the property is not found then it returns null.
		 * */
		public static function getCaseSensitivePropertyName(object:Object, propertyName:String):String {
			var properties:Array = getPropertyNames(object);
			var propertyLowerCased:String = propertyName.toLowerCase();
			
			for each (var property:String in properties) {
				if (property.toLowerCase() == propertyLowerCased) {
					return property;
				}
			}
			
			return null;
		}
		
		/**
		 * Gets the correct case of an object's style. For example, 
		 * "backgroundcolor" returns "backgroundColor".
		 * 
		 * If the style is not found then it returns null.
		 * */
		public static function getCaseSensitiveStyleName(object:Object, styleName:String):String {
			var styles:Array = getStyleNames(object);
			var styleLowerCased:String = styleName.toLowerCase();
			
			for each (var style:String in styles) {
				if (style.toLowerCase() == styleLowerCased) {
					return style;
				}
			}
			
			return null;
		}
		
		/**
		 * Gets the correct case of an objects property. For example, 
		 * "percentwidth" returns "percentWidth".  
		 * */
		public static function getCaseSensitivePropertyName2(target:Object, property:String, options:Object = null):String {
			var classInfo:Object = target ? ObjectUtil.getClassInfo(target, null, options) : property;
			var properties:Array = classInfo ? classInfo.properties : [];
			
			for each (var info:QName in properties) {
				if (info.localName.toLowerCase() == property.toLowerCase()) {
					return info.localName;
				}
			}
			
			return property;
		}
		
		/**
		 * Creates an XMLList of the property items for the given object type including super class properties. <br/><br/>
		 * 
		 * Properties including accessors and variables are included in this list. <br/><br/>
		 * 
		 * We add a few additional attributes to the metadata including the class the property is declared in,
		 * the name of the property. 
		 * 
		 * For example, if you give it a Spark Button class it gets all the
		 * information for it and all the classes that inherit from it. It then
		 * updates all that information with the class it was declared in 
		 * and so on until it gets to Object. <br/><br/>
		 * 
		 * Usage:<br/>
<pre>
var allProperties:XMLList = getPropertiesMetaData(myButton);
var buttonOnlyProperties:XMLList = getPropertiesMetaData(myButton, null, null, getQualifiedClassName(myButton));
var buttonOnlyProperties2:XMLList = getPropertiesMetaData(myButton, null, null, "spark.components::Button");
</pre>
		 * 
		 * @param object The object to inspect. Either string, object or class.
		 * @param propertyType Either accessor, variable or all. Default is all. 
		 * @param existingItems An existing list of properties
		 * @param stopAt Stops at Object unless you change this value
		 * 
		 * @see #getStyleNames()
		 * @see #getPropertyNames()
		 * @see #getMetaData()
		 * @see #getStylesMetaData()
		 * @see #getEventsMetaData()
		 * */
		public static function getPropertiesMetaData(object:Object, propertyType:String = "all", existingItems:XMLList = null, stopAt:String = null):XMLList {
			var describedTypeRecord:DescribeTypeCacheRecord = mx.utils.DescribeTypeCache.describeType(object);
			var typeDescription:* = describedTypeRecord.typeDescription;
			var hasFactory:Boolean = typeDescription.factory.length()>0;
			var factory:* = typeDescription.factory;
			var extendsClass:XMLList = hasFactory ? typeDescription.factory.extendsClass : typeDescription.extendsClass;
			var typeName:String = describedTypeRecord.typeName;
			var extendsLength:int = extendsClass.length();
			// can be on typeDescription.metadata or factory.metadata
			var isRoot:Boolean = object is String ? false : true;
			var className:String = !isRoot ? object as String : getQualifiedClassName(object);
			var itemsLength:int;
			var itemsList:XMLList;
			var existingItemsLength:int = existingItems ? existingItems.length() : 0;
			var metaName:String;
			
			const PROPERTY:String = "property";
			const VARIABLE:String = "variable";
			const ACCESSOR:String = "accessor";
			
			if (propertyType==null) propertyType = "all";
			
			if (propertyType.toLowerCase()=="accessor") {
				propertyType = "accessor";
				itemsList = hasFactory ? factory.accessor : typeDescription.accessor;
			}
			else if (propertyType.toLowerCase()=="variable") {
				propertyType = "variable";
				itemsList = hasFactory ? factory.variable : typeDescription.variable;
			}
			else {
				itemsList = hasFactory ? factory.variable : typeDescription.variable;
				itemsList = hasFactory ? itemsList+factory.accessor : itemsList+typeDescription.accessor;
			}
			
			// make a copy because modifying the xml modifies the cached xml
			itemsList = itemsList.copy();
			itemsLength = itemsList.length();
			
			
			for (var i:int;i<itemsLength;i++) {
				var item:XML = XML(itemsList[i]);
				metaName = item.@name;
				item.@metadataType = item.localName();
				item.@declaredBy = typeName;
				item.setLocalName(PROPERTY);
			
				
				for (var j:int=0;j<existingItemsLength;j++) {
					var existingItem:XML = existingItems[j];
					
					if (metaName==existingItem.@name) {
						
						if (existingItem.@metadataType==VARIABLE) {
							existingItem.@declaredBy = typeName;
						}
						else if (existingItem.@metadataType==ACCESSOR) {
							existingItem.@declaredBy = typeName;
							//existingItem.appendChild(new XML("<overrides type=\""+ className + "\"/>"));
						}
						
						delete itemsList[i];
						itemsLength--;
						i--;
						continue;
					}
				}
			}
			
			if (existingItems==null) {
				existingItems = new XMLList();
			}
			
			// add new items to previous items
			if (itemsLength>0) {
				existingItems = new XMLList(existingItems.toString()+itemsList.toString());
			}
			
			if (isRoot && extendsLength>0) {
				for (i=0;i<extendsLength;i++) {
					var newClass:String = String(extendsClass[i].@type);
					existingItems = getPropertiesMetaData(newClass, propertyType, existingItems, stopAt);
				}
				
				
				var classesToKeep:Array = [typeName];
				
				for (i=0;i<extendsLength;i++) {
					var nextClass:String = String(extendsClass[i].@type);
					classesToKeep.push(nextClass);
				}
				
				// describe type gets all the properties so after we find the class that 
				// declares them we remove the classes are not part of our request
				var classIndex:int = classesToKeep.indexOf(stopAt);
				
				if (classIndex!=-1) {
					var classFound:String = "";
					var removeItems:XMLList;
					var classToRemove:String;
					
					for (i=classIndex+1;i<classesToKeep.length;i++) {
						classToRemove = classesToKeep[i];
						existingItems = existingItems.(@declaredBy!=classToRemove);
					}
				}
				
			}
			
			return existingItems;
		}
		
		/**
		 * Creates an array of the style items for the given object type including inherited styles. <br/><br/>
		 * 
		 * Properties (accessors), variables and methods are not included in this list. See getPropertiesMetaData() <br/><br/>
		 * 
		 * We add a few additional attributes to the metadata including the class the style is declared in,
		 * the name of the style and the type of metadata as style or event. 
		 * 
		 * For example, if you give it a Spark Button class it gets all the
		 * information for it and then gets it's super class ButtonBase and 
		 * adds all that information and so on until it gets to Object. <br/><br/>
		 * 
		 * Usage:<br/>
<pre>
var allStyles:XMLList = getStyleMetaDataList(myButton);
</pre>
		 * 
		 * @param object The object to inspect. Either string, object or class.
		 * @param existingItems An existing list of styles
		 * @param stopAt Stops at Object unless you change this value
		 * 
		 * @see #getPropertiesMetaData()
		 * @see #getEventsMetaData()
		 * @see #getMetaData()
		 * */
		public static function getStylesMetaData(object:Object, existingItems:XMLList = null, stopAt:String = "Object"):XMLList {
			return getMetaData(object, STYLE, existingItems, stopAt);
		}
		
		/**
		 * Creates an array of the event items for the given object type including inherited events. <br/><br/>
		 * 
		 * Properties (accessors), variables and methods are not included in this list. <br/><br/>
		 * 
		 * We add a few additional attributes to the metadata including the class the event is declared in,
		 * the name of the event and the type of metadata as style or event. 
		 * 
		 * For example, if you give it a Spark Button class it gets all the
		 * information for it and then gets it's super class ButtonBase and 
		 * adds all that information and so on until it gets to Object. <br/><br/>
		 * 
		 * Usage:<br/>
<pre>
var allEvents:XMLList = getEventsMetaDataList(myButton);
</pre>
		 * @param object The object to inspect. Either string, object or class.
		 * @param existingItems An existing list of events
		 * @param stopAt Stops at Object unless you change this value
		 * 
		 * @see #getPropertiesMetaData()
		 * @see #getStylesMetaData()
		 * @see #getMetaData()
		 * */
		public static function getEventsMetaData(object:Object, existingItems:XMLList = null, stopAt:String = "Object"):XMLList {
			return getMetaData(object, EVENT, existingItems, stopAt);
		}
		
		/**
		 * Creates an array of the style or event items for the given object type including inherited styles and events. <br/><br/>
		 * 
		 * Properties (accessors), variables and methods are not included in this list. See getPropertiesMetaData() <br/><br/>
		 * 
		 * We add a few additional attributes to the metadata including the class the style or event is declared in,
		 * the name of the style or event and the type of metadata as style or event. 
		 * 
		 * For example, if you give it a Spark Button class it gets all the
		 * information for it and then gets it's super class ButtonBase and 
		 * adds all that information and so on until it gets to Object. <br/><br/>
		 * 
		 * Usage:<br/>
<pre>
var allStyles:XMLList = getMetaData(myButton, "Style");
</pre>
		 * @param object The object to inspect. Either string, object or class.
		 * @param metaType The name of the data in the item name property. Either Style or Event
		 * @param existingItems The list of the data in the item name property
		 * @param stopAt Stops at Object unless you change this value
		 * 
		 * @see #getPropertiesMetaData()
		 * @see #getStylesMetaData()
		 * @see #getEventsMetaData()
		 * */
		public static function getMetaData(object:Object, metaType:String, existingItems:XMLList = null, stopAt:String = "Object"):XMLList {
			var describedTypeRecord:DescribeTypeCacheRecord = mx.utils.DescribeTypeCache.describeType(object);
			var typeDescription:* = describedTypeRecord.typeDescription;
			var hasFactory:Boolean = typeDescription.factory.length()>0;
			var factory:* = typeDescription.factory;
			var extendsClass:XMLList = hasFactory ? typeDescription.factory.extendsClass : typeDescription.extendsClass;
			var extendsLength:int = extendsClass.length();
			// can be on typeDescription.metadata or factory.metadata
			var isRoot:Boolean = object is String ? false : true;
			var className:String = describedTypeRecord.typeName;
			var numberOfItems:int;
			var itemsList:XMLList;
			var existingItemsLength:int = existingItems ? existingItems.length() : 0;
			var metaName:String;
			var duplicateItems:Array = [];
			
			if (metaType.toLowerCase()=="style") {
				metaType = "Style"; 
			}
			else if (metaType.toLowerCase()=="event") {
				metaType = "Event"; 
			}
			
			if (hasFactory) {
				//itemsList = factory.metadata.(@name==name); property "name" won't work. no matches found
				itemsList = factory.metadata.(@name==metaType);
			}
			else {
				itemsList = typeDescription.metadata.(@name==metaType);
			}
			
			// make a copy because modifying the xml modifies the cached xml
			itemsList = itemsList.copy();
			numberOfItems = itemsList.length();
			
			
			for (var i:int;i<numberOfItems;i++) {
				var item:XML = XML(itemsList[i]);
				metaName = item.arg[0].@value;
				item.@name = metaName;
				item.@metadataType = metaType;
				item.@declaredBy = className;
				
				for (var j:int=0;j<existingItemsLength;j++) {
					var existingItem:XML = existingItems[j];
					
					if (metaName==existingItem.@name) {
						//existingItem.@declaredBy = className;
						existingItem.appendChild(new XML("<overrides type=\""+ className + "\"/>"));
						delete itemsList[i];
						numberOfItems--;
						i--;
						continue;
					}
				}
			}
			
			if (existingItems==null) {
				existingItems = new XMLList();
			}
			
			// add new items to previous items
			if (numberOfItems>0) {
				existingItems = new XMLList(existingItems.toString()+itemsList.toString());
			}

			if (isRoot && extendsLength>0) {
				for (i=0;i<extendsLength;i++) {
					var nextClass:String = String(extendsClass[i].@type);
					
					if (nextClass==stopAt) {
						break;
					}
					
					existingItems = getMetaData(nextClass, metaType, existingItems, stopAt);
				}
			}
			
			return existingItems;
		}
		
		/**
		 * Get AccessorMetaData data for the given property. 
		 * 
		 * @see #getMetaDataOfStyle();
		 * */
		public static function getMetaDataOfProperty(target:Object, property:String, ignoreFacades:Boolean = false):AccessorMetaData {
			var describedTypeRecord:mx.utils.DescribeTypeCacheRecord = mx.utils.DescribeTypeCache.describeType(target);
			var accessorMetaData:AccessorMetaData;
			var matches:XMLList = describedTypeRecord.typeDescription..accessor.(@name==property);
			var matches2:XMLList = describedTypeRecord.typeDescription..variable.(@name==property);
			var node:XML;
			
			if (matches.length()>0) {
				node = matches[0];
			}
			else if (matches2.length()>0) {
				node = matches2[0];
			}
			
			// we should not include facade properties
			
			var cachedMetaData:Object = DescribeTypeCacheRecord[property];
			if (cachedMetaData is AccessorMetaData) {
				AccessorMetaData(cachedMetaData).updateValues(target);
				return AccessorMetaData(cachedMetaData);
			}
			
			if (node) {
				accessorMetaData = new AccessorMetaData();
				accessorMetaData.unmarshall(node, target);
				
				// we want to cache property meta data
				if (accessorMetaData) {
					DescribeTypeCache.registerCacheHandler(property, function (record:DescribeTypeCacheRecord):Object {
						//if (relevantPropertyFacades.indexOf(style)!=-1) {
						return accessorMetaData;
						//}
					});
				}
				
				return accessorMetaData;
			}
			
			return null;
		}
		public static const relevantPropertyFacades:Array = 
			[ "top", "left", "right", "bottom", 
			"verticalCenter", "horizontalCenter", "baseline"];
		
		/**
		 * Get StyleMetaData data for the given style. 

		 * Usage:<br/>
 <pre>
 var styleMetaData:StyleMetaData = getMetaDataOfStyle(myButton, "color");
 </pre>
		 * @returns an StyleMetaData object
		 * @param target IStyleClient that contains the style
		 * @param style name of style
		 * @param type if style is not defined on target class we check super class. default null 
		 * @param stopAt if we don't want to look all the way up to object we can set the class to stop looking at
		 * 
		 * @see #getMetaDataOfProperty()
		 * */
		public static function getMetaDataOfStyle(target:Object, style:String, type:String = null, stopAt:String = null):StyleMetaData {
			var describedTypeRecord:DescribeTypeCacheRecord;
			var styleMetaData:StyleMetaData;
			var extendsClassList:XMLList;
			var typeDescription:XML;
			var foundStyle:Boolean;
			var hasFactory:Boolean;
			var matches:XMLList;
			var factory:Object;
			var node:XML;
			
			if (type) {
				describedTypeRecord = DescribeTypeCache.describeType(type);
			}
			else {
				describedTypeRecord = DescribeTypeCache.describeType(target);
			}
			
			var cachedMetaData:Object = describedTypeRecord[style];
			if (cachedMetaData is StyleMetaData) {
				StyleMetaData(cachedMetaData).updateValues(target);
				return StyleMetaData(cachedMetaData);
			}
			
			typeDescription = describedTypeRecord.typeDescription[0];
			factory = typeDescription.factory;
			hasFactory = factory.length()>0;
			
			// sometimes factory exists sometimes it doesn't wtf?
			if (hasFactory) {
				//matches = describedTypeRecord.typeDescription.factory.metadata.(@name=="Style").arg.(@value==style);
				matches = factory.metadata.(@name=="Style").arg.(@value==style);
			}
			else {
				matches = typeDescription.metadata.(@name=="Style").arg.(@value==style);
			}
			
			if (matches && matches.length()==0) {
				
				if (hasFactory) {
					extendsClassList = factory.extendsClass;
				}
				else {
					extendsClassList = typeDescription.extendsClass;
				}
				
				var numberOfTypes:int = extendsClassList.length();
				
				for (var i:int;i<numberOfTypes;i++) {
					type = extendsClassList[i].@type;
					if (type==stopAt) return null;
					if (type=="Class") return null;
					
					return getMetaDataOfStyle(target, style, type);
				}
			}
			
			if (matches.length()>0) {
				node = matches[0].parent();
				if ("typeName" in typeDescription) {
					node.@declaredBy = typeDescription.typeName;
				}
				else if (type) {
					node.@declaredBy = type;
				}
				else if (typeDescription.hasOwnProperty("name")) {
					node.@declaredBy = typeDescription.@name;
				}
				styleMetaData = new StyleMetaData();
				styleMetaData.unmarshall(node, target);
				
				// we want to cache style meta data
				if (styleMetaData) {
					//Main Thread (Suspended: Error: Error #2090: The Proxy class does not implement callProperty. It must be overridden by a subclass.)	
					//	Error$/throwError [no source]	
					//	flash.utils::Proxy/http://www.adobe.com/2006/actionscript/flash/proxy::callProperty [no source]	
						
					DescribeTypeCache.registerCacheHandler(style, function (record:DescribeTypeCacheRecord):Object {
						//if (relevantPropertyFacades.indexOf(style)!=-1) {
						return styleMetaData;
						//}
					});
				}
				
				return styleMetaData;
			}
			
			return null;
		}
		
		/**
		 * Gets an array of the styles from an array of names<br/><br/>
		 * 
		 * Usage:<br/>
 <pre>
 // returns ["backgroundAlpha", "fontFamily"]
 var styles:Array = getStylesFromArray(myButton, ["chicken","potatoe","backgroundAlpha","swisscheese","fontFamily"]);
 </pre>
		 * 
		 * @param object The object to use. Either string, object or class.
		 * @param possibleStyles An existing list of styles
		 * 
		 * @returns an array of style names or an empty array
		 * 
		 * @see #getPropertiesFromArray()
		 * */
		public static function getStylesFromArray(object:Object, possibleStyles:Object):Array {
			var styleNames:Array = getStyleNames(object);
			var result:Array = [];
			var style:String;
			var numberOfStyles:int;
			
			possibleStyles = ArrayUtil.toArray(possibleStyles);
			numberOfStyles = possibleStyles.length;
			
			for (var i:int; i < numberOfStyles; i++) {
				style = possibleStyles[i];
				
				if (styleNames.indexOf(style)!=-1) {
					if (result.indexOf(style)==-1) {
						result.push(style);
					}
				}
			}
			
			
			return result;
		}
		
		/**
		 * Gets an array of the styles from an object with name value pair<br/><br/>
		 * 
		 * Usage:<br/>
		 <pre>
		 // returns ["color", "fontFamily"]
		 var styles:Array = getStylesFromArray(myButton, {"color":10,"fontFamily":30,"marshmallow":20});
		 </pre>
		 * 
		 * @param object The object to check.
		 * @param object A generic object with properties on it.
		 * 
		 * @see #getPropertiesFromObject()
		 * */
		public static function getStylesFromObject(object:Object, possibleStyles:Object):Array {
			var propertiesNames:Array = getPropertyNames(possibleStyles);
			
			return getStylesFromArray(object, propertiesNames);
		}
		
		/**
		 * Gets an array of the properties from an object with name value pair<br/><br/>
		 * 
		 * Usage:<br/>
<pre>
// returns ["x", "width"]
var properties:Array = getPropertiesFromArray(myButton, {"x":10,"apple":30,"width":20});
</pre>
		 * 
		 * @param object The object to check.
		 * @param object A generic object with properties on it.
		 * 
		 * @see #getStylesFromObject()
		 * */
		public static function getPropertiesFromObject(object:Object, possibleProperties:Object):Array {
			var propertiesNames:Array = getPropertyNames(possibleProperties);
			
			return getPropertiesFromArray(object, propertiesNames);
		}
		
		public static var constraints:Array = ["baseline", "left", "top", "right", "bottom", "horizontalCenter", "verticalCenter"];
		
		/**
		 * Gets an array of valid properties from an array of possible property names<br/><br/>
		 * 
		 * Usage:<br/>
 <pre>
 // returns ["width", "x"]
 var properties:Array = getPropertiesFromArray(myButton, ["chicken","potatoe","width","swisscheese","x"]);
 </pre>
		 * 
		 * @param object The object to use. Either string, object or class.
		 * @param possibleProperties An list of possible properties
		 * 
		 * @returns an array of styles names or empty array
		 * 
		 * @see #getStylesFromArray()
		 * */
		public static function getPropertiesFromArray(object:Object, possibleProperties:Object, removeConstraints:Boolean = true):Array {
			var propertyNames:Array = getPropertyNames(object);
			var result:Array = [];
			var property:String;
			var numberOfProperties:int;
			
			possibleProperties = ArrayUtil.toArray(possibleProperties);
			numberOfProperties = possibleProperties.length;
			
			for (var i:int; i < numberOfProperties; i++) {
				property = possibleProperties[i];
				
				if (propertyNames.indexOf(property)!=-1) {
					if (result.indexOf(property)==-1) {
						
						if (removeConstraints) {
							// remove constraints (they are a facade for the styles)
							if (constraints.indexOf(property)==-1) { 
								result.push(property);
							}
						}
						else {
							result.push(property);
						}
					}
				}
			}
			
			
			return result;
		}
		
		
		/**
		 * Removes the constraint values from an object since the constraint properties
		 * are a facade for the styles of the same name. 
		 * Having an attribute defined twice in XML makes the XML invalid. So we must
		 * remove them.
		 * */
		public static function removeConstraintsFromObject(object:Object):Object {
			var propertyNames:Array = getPropertyNames(object);
			var numberOfProperties:int = propertyNames.length;
			var property:String;
			
			for (var i:int; i < numberOfProperties; i++) {
				property = propertyNames[i];
				
				// found constraint then delete it from the object
				if (constraints.indexOf(property)!=-1) { 
					object[property] = null;
					delete object[property];
				}
			}
			
			return object;
		}
		
		/**
		 * Gets an array of the styles from the object<br/><br/>
		 * 
		 * Usage:<br/>
		 var styles:Array = getStyleNames(myButton);
		 </pre>
		 * 
		 * @param object The object to use. Either string, object or class.
		 * */
		public static function getStyleNames(object:Object):Array {
			var stylesList:XMLList = getStylesMetaData(object);
			var styleNames:Array = XMLUtils.convertXMLListToArray(stylesList.@name);
			
			return styleNames;
		}
		
		/**
		 * Checks if the application has the definition. Returns true if it does. 
		 * */
		public static function hasDefinition(definition:String, domain:ApplicationDomain = null):Boolean {
			var isDefined:Boolean;
			
			if (domain) {
				isDefined = domain.hasDefinition(definition);
				return isDefined;
			}
			
			isDefined = ApplicationDomain.currentDomain.hasDefinition(definition);
			return isDefined;
		}
		
		/**
		 * Gets the definition if defined. If not defined returns null. 
		 * */
		public static function getDefinition(definition:String, domain:ApplicationDomain = null):Object {
			var isDefined:Boolean;
			var definedClass:Object;
			domain = domain ? domain : ApplicationDomain.currentDomain;
			
			isDefined = domain.hasDefinition(definition);
			
			if (isDefined) {
				definedClass = domain.getDefinition(definition);
			}
			
			return definedClass;
		}
		
		/**
		 * Checks if the object is empty, if it has no properties. 
		 * Uses describeType to get the metadata on the object and 
		 * checks the number of properties.
		 * */
		public static function isEmptyObject(object:Object):Boolean {
			var propertiesArray:Array = getPropertyNames(object);
			return propertiesArray==null || propertiesArray.length==0;
		}
		
		/**
		 * Get a styles type 
		 * 
<pre>
var type:String = getTypeOfStyle(myButton, "color");
trace(type); // "String"
var type:Object = getTypeOfStyle(myButton, "color", true);
trace(type); // [Object String]
</pre>
		 * */
		public static function getTypeOfStyle(elementInstance:Object, style:String, returnAsClass:Boolean = false):Object {
			var styleMetaData:StyleMetaData = getMetaDataOfStyle(elementInstance, style);
			var ClassObject:Object;
			
			if (styleMetaData) {
				
				if (returnAsClass) {
					ClassObject = getDefinition(styleMetaData.type);
					return ClassObject;
				}
				else {
					return styleMetaData.type;
				}
			}
			
			return null;
		}
		/**
		 * Get a properties type 
		 * 
<pre>
var type:String = getTypeOfProperty(myButton, "x");
trace(type); // "int"
var type:Object = getTypeOfProperty(myButton, "x", true);
trace(type); // [Object int]
</pre>
		 * */
		public static function getTypeOfProperty(elementInstance:Object, property:String, returnAsClass:Boolean = false):Object {
			var propertyMetaData:MetaData = getMetaDataOfProperty(elementInstance, property);
			var classObject:Object;
			
			if (propertyMetaData) {
				
				if (returnAsClass) {
					classObject = getDefinition(propertyMetaData.type);
					return classObject;
				}
				else {
					return propertyMetaData.type;
				}
			}
			
			return null;
		}
		
		/**
		 * Get object that has name and value pair of styles and makes sure the values are of correct type
Usage: 
<pre>
var elementInstance:UIComponent = new ComboBox();
var node = &lt;s:ComboBox height="23" x="30" y="141" width="166" dataProvider="Item 1,Item 2,Item 3" xmlns:s="library://ns.adobe.com/flex/spark" />
var elementName:String = node.localName();
var attributeName:String;
var attributes:Array;
var childNodeNames:Array;
var propertiesOrStyles:Array;
var properties:Array;
var styles:Array;
var attributesValueObject:Object;
var childNodeValueObject:Object;
var values:Object;
var valuesObject:ValuesObject;
var failedToImportStyles:Object = {};
var failedToImportProperties:Object = {};

attributes 				= XMLUtils.getAttributeNames(node);
childNodeNames 			= XMLUtils.getChildNodeNames(node);
propertiesOrStyles 		= attributes.concat(childNodeNames);
properties 				= ClassUtils.getPropertiesFromArray(elementInstance, propertiesOrStyles);
styles 					= ClassUtils.getStylesFromArray(elementInstance, propertiesOrStyles);

attributesValueObject 	= XMLUtils.getAttributesValueObject(node);
attributesValueObject	= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, attributesValueObject, styles, failedToImportStyles);
attributesValueObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, attributesValueObject, properties, failedToImportProperties);
</pre>
		 * @param target Object to set values on
		 * @param values Object containing name value pair of styles
		 * @param styles Optional Array of specific styles to
		 * @param failedToImportObject Optional Object that contains any styles that failed to import and errors as the value
		 * */
		public static function getTypedStyleValueObject(target:Object, values:Object, styles:Array = null, getTypedObject:Boolean = false, failedToImportStyles:Object = null):Object {
			var numberOfStyles:int = styles && styles.length ? styles.length : 0;
			var styleType:Object;
			var styleMetaData:StyleMetaData;
			var style:String;
			var value:*;
			
			// get specified styles
			if (styles && numberOfStyles) {
				for each (style in styles) {
					styleMetaData = getMetaDataOfStyle(target, style);
					
					if (styleMetaData.format=="Color") {
						styleType = "String";
					}
					else {
						styleType = styleMetaData.type;
					}
					
					if (styleType=="Object") {
						
						// ITextLayoutFormat
						if (style=="trackingLeft" || style=="trackingRight" || style=="lineHeight") {
							value = values[style];
							
							if (value && value.indexOf("%")!=-1) {
								styleType = "String";
							}
							else {
								styleType = "Number";
							}
						}
						//else if (style=="baselineShift" ) {
						//	value = values[style];
						//	styleType = "String";
						//}
					}
					
					try {
						values[style] = getCorrectType(values[style], styleType);
					}
					catch (error:Error) {
						if (failedToImportStyles) {
							failedToImportStyles[style] = error;
						}
					}
				}
			}
			
			// get all styles in values object
			else {
				for (style in values) {
					styleMetaData = getMetaDataOfStyle(target, style);
					
					if (styleMetaData) {
						if (styleMetaData.format=="Color") {
							styleType = "String";
						}
						else {
							styleType = styleMetaData.type;
						}
						
						
						try {
							values[style] = getCorrectType(values[style], styleType);
						}
						catch (error:Error) {
							if (failedToImportStyles) {
								failedToImportStyles[style] = error;
							}
						}
					}
				}
			}
			
			return values;
		}
		
		/**
		 * Get object that has property and value pair and makes sure the values are of correct type
Usage: 
<pre>
var elementInstance:UIComponent = new ComboBox();
var node = &lt;s:ComboBox height="23" x="30" y="141" width="166" dataProvider="Item 1,Item 2,Item 3" xmlns:s="library://ns.adobe.com/flex/spark" />
var elementName:String = node.localName();
var attributeName:String;
var attributes:Array;
var childNodeNames:Array;
var propertiesOrStyles:Array;
var properties:Array;
var styles:Array;
var attributesValueObject:Object;
var childNodeValueObject:Object;
var values:Object;
var valuesObject:ValuesObject;
var failedToImportStyles:Object = {};
var failedToImportProperties:Object = {};

attributes 				= XMLUtils.getAttributeNames(node);
childNodeNames 			= XMLUtils.getChildNodeNames(node);
propertiesOrStyles 		= attributes.concat(childNodeNames);
properties 				= ClassUtils.getPropertiesFromArray(elementInstance, propertiesOrStyles);
styles 					= ClassUtils.getStylesFromArray(elementInstance, propertiesOrStyles);

attributesValueObject 	= XMLUtils.getAttributesValueObject(node);
attributesValueObject	= ClassUtils.getTypedStyleValueObject(elementInstance as IStyleClient, attributesValueObject, styles, failedToImportStyles);
attributesValueObject	= ClassUtils.getTypedPropertyValueObject(elementInstance, attributesValueObject, properties, failedToImportProperties);
</pre>
		 * 
		 * @param target Object to set values on
		 * @param values Object containing name value pair of properties
		 * @param properties Optional Array of specific properties to
		 * @param failedToImportObject Optional Object that contains any properties that failed to import and errors as values
		 * */
		public static function getTypedPropertyValueObject(target:Object, values:Object, properties:Array = null, failedToImportObject:Object = null):Object {
			var numberOfProperties:int = properties && properties.length ? properties.length : 0;
			var propertyType:Object;
			var property:String;
			
			// get specific properties
			if (properties && numberOfProperties) {
				for each (property in properties) {
					try {
						propertyType = getTypeOfProperty(target, property, true);
						values[property] = getCorrectType(values[property], propertyType);
					}
					catch(error:Error) {
						if (failedToImportObject) {
							failedToImportObject[property] = error;
						}
					}
				}
			}
			else {
				
				// get all properties in values object
				for (property in values) {
					try {
						propertyType = getTypeOfProperty(target, property, true);
						values[property] = getCorrectType(values[property], propertyType);
					}
					catch(error:Error) {
						if (failedToImportObject) {
							failedToImportObject[property] = error;
						}
					}
				}
			}
			
			return values;
		}
		
		/**
		 * Casts the value to the correct type
		 * NOTE: May not work for colors
		 * Also supports casting to specific class. use ClassDefinition as type
		 * returns instance of flash.utils.getDefinitionByName(className)
		 * */
		public static function getCorrectType(value:String, Type:*):* {
			var typeString:String;
			var ClassDefinition:Class;
			
			if (Type==undefined || Type==null) {
				return value;
			}
			
			if (Type && !(Type is String)) {
				
				if (Type==Boolean) {
					if (value && value.toLowerCase() == "false") {
						return false;
					}
					else if (value && value.toLowerCase() == "true") {
						return true;
					}
					else if (!value) {
						return false;
					}
				}
				return Type(value);
			}
			else {
				typeString = Type;
				
				if (typeString == "Boolean" && value.toLowerCase() == "false") {
					return false;
				}
				else if (typeString == "Boolean" && value.toLowerCase() == "true") {
					return true;
				}
				else if (typeString == "Boolean" && !value) {
					return false;
				}
				else if (typeString == "Number") {
					if (value == null || value == "") {
						return undefined
					};
					return Number(value);
				}
				else if (typeString == "int") {
					if (value == null || value == "") {
						return undefined
					};
					return int(value);
				}
				else if (typeString == "String") {
					return String(value);
				}
					// TODO: Return color type1
				else if (typeString == "Color") {
					return String(value);
				}
				else if (typeString == "ClassDefinition") {
					if (value) {
						ClassDefinition = getDefinitionByName(value) as Class;
						return ClassDefinition(value);
					}
					return null;
				}
				else {
					return value;
				}
			}
		}
		
	}
}