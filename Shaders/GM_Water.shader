// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "GM/Water"
{
	Properties
	{
		[Header(Refraction)]
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.3)) = 0.1
		_Texture0("Texture 0", 2D) = "bump" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha , SrcAlpha OneMinusSrcAlpha
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile _ALPHAPREMULTIPLY_ON
		#pragma surface surf Standard keepalpha finalcolor:RefractionF noshadow exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 screenPos;
		};

		uniform sampler2D _Texture0;
		uniform sampler2D _GrabTexture;
		uniform float _ChromaticAberration;

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
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV19 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode19 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV19, 5.0 ) );
			float lerpResult38 = lerp( 0.9 , 1.2 , fresnelNode19);
			color.rgb = color.rgb + Refraction( i, o, lerpResult38, _ChromaticAberration ) * ( 1 - color.a );
			color.a = 1;
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_TexCoord33 = i.uv_texcoord * float2( 2.5,2.5 );
			float2 panner31 = ( 0.4 * _Time.y * float2( 0.1,0.1 ) + uv_TexCoord33);
			float2 panner32 = ( 0.3 * _Time.y * float2( -0.1,-0.1 ) + uv_TexCoord33);
			o.Normal = ( UnpackNormal( tex2D( _Texture0, panner31 ) ) + UnpackNormal( tex2D( _Texture0, panner32 ) ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV19 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode19 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV19, 5.0 ) );
			float4 lerpResult18 = lerp( float4(0.5147059,0.4980536,0.4049524,0) , float4(0.7642733,0.8873523,0.9117647,0) , fresnelNode19);
			o.Albedo = lerpResult18.rgb;
			o.Metallic = 0.25;
			o.Smoothness = 0.96;
			float lerpResult40 = lerp( 0.2 , 0.65 , fresnelNode19);
			o.Alpha = lerpResult40;
			o.Normal = o.Normal + 0.00001 * i.screenPos * i.worldPos;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
1927;29;1906;1004;603.5133;1.467957;1;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;33;-1393.939,311.2996;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2.5,2.5;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;32;-904.9393,466.2996;Float;False;3;0;FLOAT2;-0.1,-0.1;False;2;FLOAT2;-0.1,-0.1;False;1;FLOAT;0.3;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;26;-682.6589,239.295;Float;True;Property;_Texture0;Texture 0;2;0;Create;True;0;0;False;0;a2e1fb5944fa8b74188c89422d0153c8;None;False;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;31;-907.9393,326.2996;Float;False;3;0;FLOAT2;0.1,0.1;False;2;FLOAT2;0.1,0.1;False;1;FLOAT;0.4;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;28;-244.6589,515.295;Float;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;27;-246.6589,303.295;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;19;-403.6589,67.29498;Float;False;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;363.0607,295.2996;Float;False;Constant;_Float3;Float 3;2;0;Create;True;0;0;False;0;0.65;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;17;-367.6589,-143.705;Float;False;Constant;_Color1;Color 1;1;0;Create;True;0;0;False;0;0.7642733,0.8873523,0.9117647,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;36;184.9864,119.6595;Float;False;Constant;_Float4;Float 4;2;0;Create;True;0;0;False;0;0.9;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;362.9178,375.2985;Float;False;Constant;_Float6;Float 6;2;0;Create;True;0;0;False;0;0.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-351.6589,-321.705;Float;False;Constant;_Color0;Color 0;1;0;Create;True;0;0;False;0;0.5147059,0.4980536,0.4049524,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;37;181.9864,204.6595;Float;False;Constant;_Float5;Float 5;2;0;Create;True;0;0;False;0;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;22;183.3411,-73.70502;Float;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;False;0;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;18;-43.65894,-170.705;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;38;348.9864,134.6595;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;40;547.9178,314.2985;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;165.3411,19.29498;Float;False;Constant;_Float1;Float 1;0;0;Create;True;0;0;False;0;0.96;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;291.0607,521.2996;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;959,-95;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;GM/Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Transparent;;Geometry;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;0;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;33;0
WireConnection;31;0;33;0
WireConnection;28;0;26;0
WireConnection;28;1;32;0
WireConnection;27;0;26;0
WireConnection;27;1;31;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;18;2;19;0
WireConnection;38;0;36;0
WireConnection;38;1;37;0
WireConnection;38;2;19;0
WireConnection;40;0;39;0
WireConnection;40;1;35;0
WireConnection;40;2;19;0
WireConnection;34;0;27;0
WireConnection;34;1;28;0
WireConnection;0;0;18;0
WireConnection;0;1;34;0
WireConnection;0;3;22;0
WireConnection;0;4;23;0
WireConnection;0;8;38;0
WireConnection;0;9;40;0
ASEEND*/
//CHKSM=C13C2230482758EA53EED0BA3EBAE50A4FF45FCB