# Ideal Cel Shader (for Amplify)

A sample shader for Amplify that replicates a basic version of how the lighting in [my cel shader](https://gitlab.com/s-ilent/SCSS) works. You can use this as a base for your own cel shaders or to get a better understanding of how it works. This supports Unity GI (realtime and indirect light) and you can specify a shading colour and shade shift. 

For more idealness, try these additions! 
1. Make the indirect light use a different texture instead of tinting the albedo. Or make it an option.
2. Instead of just a shade shift slider, why not have a shade shift texture?
3. Try splitting the lighting calculation into two! If you do it twice, once for indirect, and once for direct, you can integrate shadows cleanly. 
4. This is obviously pretty basic. No normal maps, no emission, no specular, and no outlines. Try adding your own!
