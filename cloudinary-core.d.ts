declare module 'cloudinary-core' {

    export function crc32(str: string): any;
    export function utf8_encode(argString: string): any;

    export class Util {
        allStrings(list);
        camelCase(source);
        convertKeys(source, converter);
        defaults();
        snakeCase(source);
        without(array, item);
        isNumberLike(value);
        smartEscape(string, unsafe);
        withCamelCaseKeys(source);
        withSnakeCaseKeys(source);
        hasClass(element: Element, name: string);
        addClass(element: Element, name: string);
        getAttribute(element: Element, name: string);
        setAttribute(element: Element, name: string, value: any);
        removeAttribute(element: Element, name: string);
        setAttributes(element: Element, attributes: Array<any>);
        getData(element: Element, name: string);
        setData(element: Element, name: string, value: any);
        width(element: Element);
        isStringisString(value: any);
        isArrayisArray();
        isEmptyisEmpty(value: any);
        assign(object, sources);
        merge(object, sources);
        cloneDeepcloneDeep(value: any);
        compactcompact(array: Array<any>);
        containsincludes(collection: Array<any>, value, fromIndex: number, guard);
        difference(array: Array<any>, values: Array<any>);
        isFunctionisFunction(value);
        functionsfunctions(object);
        identityidentity(value);
        isPlainObjectisPlainObject(value);
        trimtrim(string, chars, guard);        
    }

    /**
     * Represents a transformation condition
     * @param {string} conditionStr - a condition in string format
     * @class Condition
     * @example
     * // normally this class is not instantiated directly */
    export function Condition(conditionStr: string): void;

    /**
     *  Represents a single transformation.
     *  @class Transformation
     *  @example
     *  t = new cloudinary.Transformation();
     * t.angle(20).crop("scale").width("auto");
     *
     * // or
     *
     * t = new cloudinary.Transformation( {angle: 20, crop: "scale", width: "auto"});
     */
    export function Transformation(options: TransformationOptions);

    export interface TransformationOptions {
        angle?: Array<string>,
        audioCodec?: string,
        audioFrequency?: string,
        aspectRatio?: string,
        background?: string,
        bitRate?: string,
        border?: string,
        color?: string,
        colorSpace?: string,
        crop?: string,
        defaultImage?: string,
        delay?: string,
        density?: string,
        duration?: string,
        dpr?: string,
        effect?: string,
        endOffset?: string,
        fallbackContent?: string,
        fetchFormat?: string,
        format?: string,
        flags?: string,
        gravity?: string,
        height?: string;
        htmlHeight?: string;
        htmlWidth?: string;
        keyframeInterval?: string;
        offset?: string|Function|Array<any>;
        opacity?: string;
        overlay?: string; // what's a layer param?
        page?: string;
        poster?: string;
        prefix?: string;
        quality?: string;
        radius?: string;
        rawTransformation?: any;
        size?: string;
        sourceType?: string;
        sourceTransformation?: string;
        startOffset?: any;
        streamingProfile?: string;
        transformation?: any;
        underlay? : string;
        videoCodec?: string;
        videoSampling?: string;
        width?: string;
        x?: number;
        y?: number;
        zoom?: number;
    }

    /**
     * Cloudinary configuration class
     * @constructor Configuration
     * @param {Object} options - configuration parameters
     */
    export function Configuration(options);

    export interface ConfigurationOptions {
        responsive_class?: string;
        responsive_use_breakpoints?: boolean;
        round_dpr?: boolean;
        secure?: boolean;        
    }

    /**
     * Represents an HTML (DOM) tag
     * @constructor HtmlTag
     * @param {string} name - the name of the tag
     * @param {string} [publicId]
     * @param {Object} options
     * @example tag = new HtmlTag( 'div', { 'width': 10})
     */
    export interface HtmlTag {
      constructor (name: string, publicId: string, options?: TransformationOptions);
    }

    /**
     * Creates an HTML (DOM) Image tag using Cloudinary as the source.
     * @constructor ImageTag
     * @extends HtmlTag
     * @param {string} [publicId]
     * @param {Object} [options]
     */    
    export interface ImageTag {
      constructor (publicId: string, options?: TransformationOptions);
    }

    /**
     * Creates an HTML (DOM) Video tag using Cloudinary as the source.
     * @constructor VideoTag
     * @extends HtmlTag
     * @param {string} [publicId]
     * @param {Object} [options]
     */    
    export interface VideoTag{
      constructor (publicId: string, options?: TransformationOptions);
    }

    /**
     * Creates an HTML (DOM) Meta tag that enables client-hints.
     * @constructor ClientHintsMetaTag
     * @extends HtmlTag
     */
    export function ClientHintsMetaTag(options?: TransformationOptions);

    /**
     * Layer
     * @constructor Layer
     * @param {Object} options - layer parameters
     */
    export function Layer(options?: LayerOptions);

    export interface LayerOptions {
        resourceType?: string;
        type?: string;
        publicId?: string;
    }

    /**
     * @constructor TextLayer
     * @param {Object} options - layer parameters
     */
    export function TextLayer(options?: TextLayerOptions);

    export interface TextLayerOptions {
        resourceType?: string;
        fontFamily?: string;
        fontSize?: string;
        fontWeight?: string;
        fontStyle?: string;
        textDecoration?: string;
        textAlign?: string;
        stroke?: string;
        letterSpacing?: string;
        lineSpacing?: string;
        text?: string;       
    }

    /**
     * Represent a subtitles layer
     * @constructor SubtitlesLayer
     * @param {Object} options - layer parameters
     */
    export function SubtitlesLayer(options);


    /**
     * Main Cloudinary class
     * @class Cloudinary
     * @param {Object} options - options to configure Cloudinary
     * @see Configuration for more details
     * @example
     *    var cl = new cloudinary.Cloudinary( { cloud_name: "mycloud"});
     *    var imgTag = cl.image("myPicID");
     */
    export class Cloudinary {
        constructor (options: Configuration);

        /**
         * Generate an resource URL.
         * @function Cloudinary#url
         * @param {string} publicId - the public ID of the resource
         * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
         *                          and {@link Configuration} parameters
        //???  * @param {string} [options.type='upload'] - the classification of the resource
        //???  * @param {Object} [options.resource_type='image'] - the type of the resource
         * @return {string} The resource URL
         */        
         url(publicId: string, options: TransformationOptions): string;

        /**
         * Generate an video resource URL.
         * @function Cloudinary#video_url
         * @param {string} publicId - the public ID of the resource
         * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
         *                          and {@link Configuration} parameters
         * @param {string} [options.type='upload'] - the classification of the resource
         * @return {string} The video URL
         */
         video_url(publicId: string, options?: TransformationOptions);

        /**
         * Generate an image tag.
         * @function Cloudinary#image
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        image(publicId: string, options?: TransformationOptions): HTMLImageElement;

        /**
         * Generate an video thumbnail URL.
         * @function Cloudinary#video_thumbnail_url
         * @param {string} publicId - the public ID of the resource
         * @param {Object} [options] - options for the tag and transformations, possible values include all {@link Transformation} parameters
         *                          and {@link Configuration} parameters
         * @param {string} [options.type='upload'] - the classification of the resource
         * @return {string} The video thumbnail URL
         */
        video_thumbnail_url(publicId: string, options?: TransformationOptions): string;

        /**
         * Generate a string representation of the provided transformation options.
         * @function Cloudinary#transformation_string
         * @param {Object} options - the transformation options
         * @returns {string} The transformation string
         */
        transformation_string(options: TransformationOptions): string;

        /**
         * Generate an image tag.
         * @function Cloudinary#image
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        image(publicId: string, options?: TransformationOptions): HTMLImageElement; 

        /**
         * Creates a new ImageTag instance, configured using this own's configuration.
         * @function Cloudinary#imageTag
         * @param {string} publicId - the public ID of the resource
         * @param {Object} options - additional options to pass to the new ImageTag instance
         * @return {ImageTag} An ImageTag that is attached (chained) to this Cloudinary instance
         */
        imageTag(publicId: string, options?: TransformationOptions): ImageTag;

        /**
         * Generate an image tag for the video thumbnail.
         * @function Cloudinary#video_thumbnail
         * @param {string} publicId - the public ID of the video
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} An image tag element
         */
        video_thumbnail(publicId: string, options?: TransformationOptions): HTMLImageElement;

        /**
         * @function Cloudinary#facebook_profile_image
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        facebook_profile_image(publicId: string, options?: TransformationOptions): HTMLImageElement;

        /**
         * @function Cloudinary#twitter_profile_image
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        twitter_profile_image(publicId: string, options?: TransformationOptions): HTMLImageElement;

        /**
         * @function Cloudinary#twitter_name_profile_image
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        twitter_name_profile_image(publicId: string, options?: TransformationOptions): HTMLImageElement;
        
        /**
         * @function Cloudinary#gravatar_image
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        gravatar_image(publicId: string, options?: TransformationOptions): HTMLImageElement;

        /**
         * @function Cloudinary#fetch_image
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        fetch_image(publicId: string, options?: TransformationOptions): HTMLImageElement;

        /**
         * @function Cloudinary#video
         * @param {string} publicId - the public ID of the image
         * @param {Object} [options] - options for the tag and transformations
         * @return {HTMLImageElement} an image tag element
         */
        video(publicId: string, options?: TransformationOptions): HTMLImageElement;

        /**
         * Creates a new VideoTag instance, configured using this own's configuration.
         * @function Cloudinary#videoTag
         * @param {string} publicId - the public ID of the resource
         * @param {Object} options - additional options to pass to the new VideoTag instance
         * @return {VideoTag} A VideoTag that is attached (chained) to this Cloudinary instance
         */
        videoTag(publicId: string, options?: TransformationOptions): VideoTag;                          

        /**
         * Generate the URL of the sprite image
         * @function Cloudinary#sprite_css
         * @param {string} publicId - the public ID of the resource
         * @param {Object} [options] - options for the tag and transformations
         * @see {@link http://cloudinary.com/documentation/sprite_generation Sprite generation}
         */
        sprite_css(publicId: string, options?: TransformationOptions): string;

        /**
        * Initialize the responsive behaviour.<br>
        * Calls {@link Cloudinary#cloudinary_update} to modify image tags.
            * @function Cloudinary#responsive
        * @param {Object} options
        * @param {String} [options.responsive_class='cld-responsive'] - provide an alternative class used to locate img tags
        * @param {number} [options.responsive_debounce=100] - the debounce interval in milliseconds.
        * @param {boolean} [bootstrap=true] if true processes the img tags by calling cloudinary_update. When false the tags will be processed only after a resize event.
        * @see {@link Cloudinary#cloudinary_update} for additional configuration parameters
            */
        responsive(options?: TransformationOptions, bootstrap?: boolean): void;

        /**
        * Finds all `img` tags under each node and sets it up to provide the image through Cloudinary
        * @param {Element[]} nodes the parent nodes to search for img under
        * @param {Object} [options={}] options and transformations params
        * @function Cloudinary#processImageTags
        */
        processImageTags(nodes: Element[], options?: TransformationOptions): Cloudinary;    

        /**
        * Update hidpi (dpr_auto) and responsive (w_auto) fields according to the current container size and the device pixel ratio.
        * Only images marked with the cld-responsive class have w_auto updated.
        * @function Cloudinary#cloudinary_update
        * @param {(Array|string|NodeList)} elements - the elements to modify
        * @param {Object} options
        * @param {boolean|string} [options.responsive_use_breakpoints=true]
        *  - when `true`, always use breakpoints for width
        * - when `"resize"` use exact width on first render and breakpoints on resize
        * - when `false` always use exact width
        * @param {boolean} [options.responsive] - if `true`, enable responsive on this element. Can be done by adding cld-responsive.
        * @param {boolean} [options.responsive_preserve_height] - if set to true, original css height is preserved.
        *   Should only be used if the transformation supports different aspect ratios.
        */
        cloudinary_update(elements: Array<string> | NodeList, options?: TransformationOptions): Cloudinary;

        /**
         * Provide a transformation object, initialized with own's options, for chaining purposes.
         * @function Cloudinary#transformation
         * @param {Object} options
         * @return {Transformation}
         */
        transformation(options: TransformationOptions): any;    
    }
    
    export const VERSION: string;

    export interface Configuration {
        responsive_class?: string;
        responsive_use_breakpoints?: boolean;
        round_dpr?: boolean;
        secure?: boolean;

        api_key?: string; 
        api_secret?: string; 
        cdn_subdomain?: string; 
        cloud_name: string; 
        cname?: string; 
        private_cdn?: boolean;
        protocol?: string;
        resource_type?: string;
        responsive?: string;
        responsive_width?: string;
        secure_cdn_subdomain?: string;
        secure_distribution?: boolean; 
        shorten?: string;
        type?: string;
        url_suffix?: string;
        use_root_path?: string;
        version?: string;

        static_image_support?: string;
        enhance_image_tag?: boolean;
    }
}
