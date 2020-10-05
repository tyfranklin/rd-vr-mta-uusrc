// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GM/Glass"
{
	Properties
	{
		[Header(Refraction)]
		_Smoothness("Smoothness", Range( 1 , 7.5)) = 1
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_Basecolor_OpacityA("Basecolor_Opacity(A)", 2D) = "white" {}
		_Opacity_Strength("Opacity_Strength", Range( -3 , 3)) = 0
		_Contrast("Contrast", Range( 0 , 0.56)) = 0.4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#pragma surface surf Standard alpha:fade keepalpha finalcolor:RefractionF noshadow exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _Basecolor_OpacityA;
		uniform float4 _Basecolor_OpacityA_ST;
		uniform float _Contrast;
		uniform float _Smoothness;
		uniform float _Opacity_Strength;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;


		float4 CalculateContrast( float contrastValue, float4 colorTarget )
		{
			float t = 0.5 * ( 1.0 - contrastValue );
			return mul( float4x4( contrastValue,0,0,t, 0,contrastValue,0,t, 0,0,contrastValue,t, 0,0,0,1 ), colorTarget );
		}

		inline float4 Refraction( Input i, SurfaceOutputStandard o, float indexOfRefraction, float chomaticAberration ) {
			float3 worldNormal = o.Normal;
			float4 screenPos = i.screenPos;
			#if UNITY_UV_STARTS_AT_TOP
				float scale = -1.0;
			#else
				float scale = 1.0;
			#endif
			float halfPosW = screenPos.w * 0.5;
			screenPos.y = ( screenPos.y - halfPosW ) * _ProjectionParams.x * scale + halfPosW;
			#if SHADER_API_D3D9 || SHADER_API_D3D11
				screenPos.w += 0.00000000001;
			#endif
			float2 projScreenPos = ( screenPos / screenPos.w ).xy;
			float3 worldViewDir = normalize( UnityWorldSpaceViewDir( i.worldPos ) );
			float3 refractionOffset = ( ( ( ( indexOfRefraction - 1.0 ) * mul( UNITY_MATRIX_V, float4( worldNormal, 0.0 ) ) ) * ( 1.0 / ( screenPos.z + 1.0 ) ) ) * ( 1.0 - dot( worldNormal, worldViewDir ) ) );
			float2 cameraRefraction = float2( refractionOffset.x, -( refractionOffset.y * _ProjectionParams.x ) );
			float4 redAlpha = tex2D( _GrabTexture, ( projScreenPos + cameraRefraction ) );
			float green = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 - chomaticAberration ) ) ) ).g;
			float blue = tex2D( _GrabTexture, ( projScreenPos + ( cameraRefraction * ( 1.0 + chomaticAberration ) ) ) ).b;
			return float4( redAlpha.r, green, blue, redAlpha.a );
		}

		void RefractionF( Input i, SurfaceOutputStandard o, inout half4 color )
		{
			#ifdef UNITY_PASS_FORWARDBASE
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV9 = dot( ase_worldNormal, ase_worldlightDir );
			float fresnelNode9 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV9, 5.0 ) );
			float lerpResult8 = lerp( 1.0 , 1.03 , fresnelNode9);
			color.rgb = color.rgb + Refraction( i, o, lerpResult8, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_Basecolor_OpacityA = i.uv_texcoord * _Basecolor_OpacityA_ST.xy + _Basecolor_OpacityA_ST.zw;
			float4 tex2DNode1 = tex2D( _Basecolor_OpacityA, uv_Basecolor_OpacityA );
			o.Albedo = tex2DNode1.rgb;
			float grayscale11 = Luminance(CalculateContrast(_Contrast,tex2DNode1).rgb);
			o.Smoothness = ( grayscale11 * _Smoothness );
			o.Alpha = ( tex2DNode1.a * _Opacity_Strength );
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
2075;102;1906;1004;874.6262;602.1811;1;True;True
Node;AmplifyShaderEditor.TexturePropertyNode;2;-756,-229;Float;True;Property;_Basecolor_OpacityA;Basecolor_Opacity(A);2;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-553.6262,-362.1811;Float;False;Property;_Contrast;Contrast;4;0;Create;True;0;0;False;0;0.4;0;0;0.56;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-436,-173;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleContrastOpNode;14;-119.6262,-432.1811;Float;False;2;1;COLOR;0,0,0,0;False;0;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-65,305;Float;False;Constant;_Float1;Float 1;2;0;Create;True;0;0;False;0;1.03;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;9;-243,448;Float;False;Standard;WorldNormal;LightDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-57,203;Float;False;Constant;_Float0;Float 0;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCGrayscale;11;92,-345;Float;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-400,116;Float;False;Property;_Opacity_Strength;Opacity_Strength;3;0;Create;True;0;0;False;0;0;-3;-3;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;13;15.37378,-229.1811;Float;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;1;0;1;7.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;347.3738,-332.1811;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;8;148,265;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-50,40;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;268,-68;Float;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;549,-185;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;GM/Glass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;False;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;0;0;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;1;0;2;0
WireConnection;14;1;1;0
WireConnection;14;0;15;0
WireConnection;11;0;14;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;8;2;9;0
WireConnection;3;0;1;4
WireConnection;3;1;4;0
WireConnection;0;0;1;0
WireConnection;0;4;12;0
WireConnection;0;8;8;0
WireConnection;0;9;3;0
ASEEND*/
//CHKSM=932AA0A5C79CC6FAE4263E5B325A43F640A842EF