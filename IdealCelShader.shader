// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Silent/IdealCelShader"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_ShadeColour("Shade Colour", Color) = (0.5604841,0.4414383,0.6037736,0)
		_ShadingShift("Shading Shift", Range( -1 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 worldPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _ShadeColour;
		uniform float _ShadingShift;


		float3 SimpleIndirectDiffuseLight( float3 normal )
		{
			return SHEvalLinearL0L1(float4(normal, 1.0));
		}


		float3 indirectDir(  )
		{
			return normalize(0.001 + unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
		}


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode8 = tex2D( _MainTex, uv_MainTex );
			float3 normal58 = float4(0,0,0,1).xyz;
			float3 localSimpleIndirectDiffuseLight58 = SimpleIndirectDiffuseLight( normal58 );
			float3 litIndirect11 = localSimpleIndirectDiffuseLight58;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float3 localindirectDir2 = indirectDir();
			float3 indirectDir20 = localindirectDir2;
			float3 normal59 = indirectDir20;
			float3 localSimpleIndirectDiffuseLight59 = SimpleIndirectDiffuseLight( normal59 );
			float4 litDirect10 = ( ase_lightColor + float4( localSimpleIndirectDiffuseLight59 , 0.0 ) );
			float4 temp_output_37_0 = ( litDirect10 * tex2DNode8 );
			float4 lerpResult48 = lerp( ( tex2DNode8 * float4( litIndirect11 , 0.0 ) ) , temp_output_37_0 , _ShadeColour);
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_vertexNormal = mul( unity_WorldToObject, float4( ase_worldNormal, 0 ) );
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float grayscale74 = Luminance(litDirect10.rgb);
			float3 normalizeResult26 = normalize( ( ( ase_lightColor.a * ase_worldlightDir ) + ( indirectDir20 * grayscale74 ) ) );
			float3 mergedLightDir38 = normalizeResult26;
			float dotResult28 = dot( ase_worldNormal , mergedLightDir38 );
			float smoothstepResult34 = smoothstep( 0.0 , fwidth( ase_vertexNormal ).x , ( dotResult28 + _ShadingShift ));
			float diffuseShading66 = smoothstepResult34;
			float4 lerpResult29 = lerp( lerpResult48 , temp_output_37_0 , diffuseShading66);
			#ifdef UNITY_PASS_FORWARDBASE
				float4 staticSwitch50 = lerpResult29;
			#else
				float4 staticSwitch50 = ( lerpResult29 * ase_lightAtten );
			#endif
			c.rgb = ( 0.8 * staticSwitch50 ).rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows noshadow novertexlights nolightmap  nodynlightmap nodirlightmap 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18800
2137;1262;1586;836;1330.012;473.6465;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;43;-3077.597,-787.86;Inherit;False;426.5425;172.4338;Get indirect light dominant direction;2;20;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CustomExpressionNode;2;-3020.597,-711.9391;Inherit;False;return normalize(0.001 + unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz)@;3;False;0;indirectDir;False;False;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;12;-3082.861,-592.147;Inherit;False;902.7302;452;Direct and indirect lighting;8;5;6;7;10;11;21;58;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-2896.142,-715.8603;Inherit;False;indirectDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;21;-3040.07,-419.57;Inherit;False;20;indirectDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;59;-2844.523,-413.7765;Inherit;False;return SHEvalLinearL0L1(float4(normal, 1.0))@;3;False;1;True;normal;FLOAT3;0,0,0;In;;Inherit;False;Simple Indirect Diffuse Light;False;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;6;-2783.261,-542.1469;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-2553.16,-501.847;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;10;-2424.477,-507.5662;Inherit;False;litDirect;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;27;-3083.774,-126.4048;Inherit;False;765.4169;555.4298;Mix realtime and indirect light direction (won't work for shadows);8;70;22;24;14;26;25;23;74;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;71;-3060.51,317.4619;Inherit;False;10;litDirect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;23;-2990.965,-76.40482;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;24;-3055.266,183.826;Inherit;False;20;indirectDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;14;-3069.383,39.4253;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TFHCGrayscale;74;-2883.51,315.4619;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-2803.564,-44.9048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-2801.331,168.9494;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-2622.464,130.7753;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;26;-2494.213,128.0753;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-2305.82,121.5423;Inherit;False;mergedLightDir;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;13;-1946.974,-110.6766;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector4Node;5;-3039.861,-336.1471;Inherit;False;Constant;_NoDirection;NoDirection;0;0;Create;True;0;0;0;False;0;False;0,0,0,1;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;54;-1666.594,221.3283;Inherit;False;428.399;230.6153;Anti-aliased sharp lighting transition;2;47;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-1983.347,32.58102;Inherit;False;38;mergedLightDir;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-2017.942,128.1333;Inherit;False;Property;_ShadingShift;Shading Shift;2;0;Create;True;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;58;-2841.253,-330.1251;Inherit;False;return SHEvalLinearL0L1(float4(normal, 1.0))@;3;False;1;True;normal;FLOAT3;0,0,0;In;;Inherit;False;Simple Indirect Diffuse Light;False;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-1683.658,8.38571;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;47;-1616.594,272.9435;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;11;-2423.171,-329.281;Inherit;False;litIndirect;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FWidthOpNode;35;-1401.195,271.3283;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;-1399.725,109.8153;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;34;-1168.195,227.3282;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-1882.229,-398.0343;Inherit;False;11;litIndirect;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;8;-1992.111,-603.5384;Inherit;True;Property;_MainTex;Albedo;0;0;Create;False;0;0;0;False;0;False;-1;None;ba61e7145c45af04d96c0e57118ae77b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;30;-1873.354,-318.6358;Inherit;False;10;litDirect;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1599,-313;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;9;-1681.433,-214.1861;Inherit;False;Property;_ShadeColour;Shade Colour;1;0;Create;True;0;0;0;False;0;False;0.5604841,0.4414383,0.6037736,0;0.9803922,0.854902,0.8196079,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-993.6472,222.4688;Inherit;False;diffuseShading;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1600,-416;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-1347.106,-236.0555;Inherit;False;66;diffuseShading;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;48;-1335.25,-384.4902;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;29;-1072.998,-334.8482;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;49;-1066.918,-434.688;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-846.8574,-393.2207;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;60;-4012.155,-770.0258;Inherit;False;890.6704;473.3727;Notes on Indirect Light;3;64;63;62;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StaticSwitch;50;-680.2321,-365.0077;Inherit;False;Property;_Keyword1;Keyword 1;3;0;Create;True;0;0;0;False;0;False;0;0;0;False;UNITY_PASS_FORWARDBASE;Toggle;2;Key0;Key1;Fetch;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;62;-3993.455,-722.3841;Inherit;False;849;134;This node properly samples all types of indirect light, but that's not what we want! ;1;61;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-699.7676,-454.6934;Inherit;False;Constant;_LightWrappingCompensation;Light Wrapping Compensation;3;0;Create;True;0;0;0;False;0;False;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;45;-204.6167,-744.9126;Inherit;False;144.7333;110.7198;;1;46;Notes;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;63;-3992.388,-460.7369;Inherit;False;849;134;This function calls the internal function for L0/L1 probe sampling directly. ;1;65;;1,1,1,1;0;0
Node;AmplifyShaderEditor.IndirectDiffuseLighting;61;-3943.454,-672.3841;Inherit;False;Tangent;1;0;FLOAT3;0,0,1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;65;-3946.06,-412.0861;Inherit;False;return SHEvalLinearL0L1(float4(normal, 1.0))@;3;False;1;True;normal;FLOAT3;0,0,0;In;;Inherit;False;Simple Indirect Diffuse Light;False;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CustomExpressionNode;46;-192.4225,-707.4913;Inherit;False;/*$$For more idealness, change the following:$1. Make the indirect light use a different texture instead of albedo. Or make it an option.$2. Instead of just a shade shift slider, why not have a shade shift texture?$3. Try splitting the lighting calculation into two! If you do it twice, once for indirect, and once for direct, you can integrate shadows cleanly. $4. This is obviously pretty basic. No normal maps, emission maps, and no outlines. Try making your own!$$$*/;7;False;0;Notes;True;False;0;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;-380.4739,-383.5485;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-241.4635,-612.8721;Float;False;True;-1;2;ASEMaterialInspector;0;0;CustomLighting;Silent/IdealCelShader;False;False;False;False;False;True;True;True;True;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;64;-3991.388,-575.7369;Inherit;False;845;100;We only want to read the basic light probe values so we can select the light from one direction.;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;1;-3080.66,-903.775;Inherit;False;499.7419;100;-- Silent;0;You may not like it, but this is what the ideal cel shader looks like.;1,1,1,1;0;0
WireConnection;20;0;2;0
WireConnection;59;0;21;0
WireConnection;7;0;6;0
WireConnection;7;1;59;0
WireConnection;10;0;7;0
WireConnection;74;0;71;0
WireConnection;22;0;23;2
WireConnection;22;1;14;0
WireConnection;70;0;24;0
WireConnection;70;1;74;0
WireConnection;25;0;22;0
WireConnection;25;1;70;0
WireConnection;26;0;25;0
WireConnection;38;0;26;0
WireConnection;58;0;5;0
WireConnection;28;0;13;0
WireConnection;28;1;39;0
WireConnection;11;0;58;0
WireConnection;35;0;47;0
WireConnection;41;0;28;0
WireConnection;41;1;40;0
WireConnection;34;0;41;0
WireConnection;34;2;35;0
WireConnection;37;0;30;0
WireConnection;37;1;8;0
WireConnection;66;0;34;0
WireConnection;36;0;8;0
WireConnection;36;1;31;0
WireConnection;48;0;36;0
WireConnection;48;1;37;0
WireConnection;48;2;9;0
WireConnection;29;0;48;0
WireConnection;29;1;37;0
WireConnection;29;2;67;0
WireConnection;51;0;29;0
WireConnection;51;1;49;0
WireConnection;50;1;51;0
WireConnection;50;0;29;0
WireConnection;68;0;69;0
WireConnection;68;1;50;0
WireConnection;0;13;68;0
ASEEND*/
//CHKSM=6ADCA057390BF1E7C29FE2DFBABB9B8794CFC391