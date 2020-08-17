// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/WaterRefractionShader"
{
	Properties
	{
		_RippleCutoff("Ripple Cutoff", Float) = 0
		_DisortedNoiseScale("DisortedNoise Scale", Float) = 0
		_NoiseScrollSpeed("Noise Scroll Speed", Float) = 0
		_DistortionTexture("Distortion Texture", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_FoamThickness("Foam Thickness", Float) = 0
		_RrefractionDistortion("Rrefraction Distortion", Float) = 0
		_EdgeColor("Edge Color", Color) = (0,0,0,0)
		_DepthColor("Depth Color", Color) = (0,0,0,0)
		_Depthoffsetcoloring("Depth offset coloring", Float) = 0
		_FoamCutoff("Foam Cutoff", Float) = 0
		_FoamCutoffSoftness("Foam Cutoff Softness", Float) = 0
		_MainText("Main Text", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityCG.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float4 screenPos;
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _FoamCutoff;
		uniform float _FoamCutoffSoftness;
		UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _FoamThickness;
		uniform sampler2D _TextureSample1;
		uniform float _DisortedNoiseScale;
		uniform sampler2D _DistortionTexture;
		uniform float _NoiseScrollSpeed;
		uniform sampler2D _CameraOpaqueTexture;
		uniform float _RrefractionDistortion;
		uniform float _RippleCutoff;
		uniform sampler2D _GlobalEffectRT;
		uniform float3 _Position;
		uniform float _OrthographicCamSize;
		uniform float4 _EdgeColor;
		uniform float4 _DepthColor;
		uniform float _Depthoffsetcoloring;
		uniform sampler2D _MainText;
		uniform float4 _MainText_ST;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth46 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
			float distanceDepth46 = abs( ( screenDepth46 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 1.0 ) );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float temp_output_71_0 = ( distanceDepth46 - ( ase_grabScreenPosNorm.w - _FoamThickness ) );
			float temp_output_52_0 = ( 1.0 - temp_output_71_0 );
			float4 break31 = ( _DisortedNoiseScale * ase_grabScreenPosNorm );
			float4 appendResult37 = (float4(break31.x , 0.0 , break31.z , 0.0));
			float4 temp_cast_1 = (tex2D( _DistortionTexture, ( appendResult37 + ( _Time.y * _NoiseScrollSpeed ) ).xy ).r).xxxx;
			float4 tex2DNode44 = tex2D( _TextureSample1, (appendResult37*1.0 + ( ( appendResult37 - temp_cast_1 ) * 0.0 )).xy );
			float smoothstepResult80 = smoothstep( ( _FoamCutoff + _FoamCutoffSoftness ) , ( temp_output_52_0 + ( temp_output_52_0 * tex2DNode44.r ) ) , _FoamCutoff);
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 appendResult7 = (float4(ase_vertex3Pos.x , 0.0 , ase_vertex3Pos.z , 0.0));
			float4 appendResult12 = (float4(_Position.x , 0.0 , _Position.z , 0.0));
			float4 tex2DNode18 = tex2D( _GlobalEffectRT, ( ( ( appendResult7 - appendResult12 ) / ( _OrthographicCamSize * 2.0 ) ) + float4( float2( 0.5,0.5 ), 0.0 , 0.0 ) ).xy );
			float smoothstepResult22 = smoothstep( ( _RippleCutoff + tex2DNode18.b ) , tex2DNode18.b , _RippleCutoff);
			float4 temp_output_85_0 = ( tex2D( _CameraOpaqueTexture, (ase_grabScreenPosNorm*1.0 + ( tex2DNode44.r * _RrefractionDistortion )).xy ) + smoothstepResult22 );
			float4 lerpResult69 = lerp( _EdgeColor , _DepthColor , saturate( ( _Depthoffsetcoloring * ( distanceDepth46 - ase_grabScreenPosNorm.w ) ) ));
			float2 uv_MainText = i.uv_texcoord * _MainText_ST.xy + _MainText_ST.zw;
			o.Albedo = saturate( ( ( smoothstepResult80 + ( temp_output_85_0 + ( temp_output_85_0 + ( lerpResult69 * ( temp_output_71_0 + tex2DNode44.r ) ) ) ) ) * tex2D( _MainText, uv_MainText ) ) ).rgb;
			float3 temp_cast_8 = (saturate( ( smoothstepResult80 + smoothstepResult22 ) )).xxx;
			o.Emission = temp_cast_8;
			o.Smoothness = tex2DNode44.r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18301
0;510;1368;489;-939.511;516.8806;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;45;-3768.749,-319.8439;Inherit;False;2535.282;865.1196;Distorted Noise;16;38;37;36;31;33;35;30;25;29;34;42;41;40;43;44;114;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;114;-3729.216,-167.724;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;25;-3718.749,-269.8439;Inherit;False;Property;_DisortedNoiseScale;DisortedNoise Scale;2;0;Create;True;0;0;False;0;False;0;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-3438.798,-238.1148;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleTimeNode;35;-3135.197,302.9957;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-3165.838,429.2757;Inherit;False;Property;_NoiseScrollSpeed;Noise Scroll Speed;3;0;Create;True;0;0;False;0;False;0;0.18;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;31;-3241.783,-85.97939;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;37;-2848.884,-69.76208;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-2917.119,326.1908;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-2700.381,254.1352;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2339.237,724.217;Inherit;False;2322.299;811.2761;RenderTexture UV / Ripples;16;17;12;11;13;15;14;16;20;7;18;2;3;19;22;21;28;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;38;-2533.115,223.7618;Inherit;True;Property;_DistortionTexture;Distortion Texture;4;0;Create;True;0;0;False;0;False;-1;None;05b24a97c1b636f4a9767a80e814a008;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PosVertexDataNode;28;-2248.215,804.9163;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;3;-2239.848,1191.5;Inherit;False;Global;_Position;_Position;1;0;Create;True;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-2153.395,87.43739;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;7;-1951.307,837.7256;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1650.748,1419.493;Inherit;False;Constant;_2;2;1;0;Create;True;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;53;-2623.289,-1106.071;Inherit;False;1329.525;674.1619;Foam Line;9;47;48;50;46;52;71;70;74;116;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-1774.247,1270.693;Inherit;False;Global;_OrthographicCamSize;_OrthographicCamSize;0;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;12;-1913.556,1193.667;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2178.316,226.6674;Inherit;False;Constant;_NoiseDistortion;Noise Distortion;5;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1974.872,143.639;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1461.302,1290.484;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-1687.478,1025.548;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GrabScreenPosition;116;-2543.863,-914.5021;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;43;-1802.715,-3.735931;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;17;-1236.328,1296.949;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-1253.58,1134.547;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-2158.823,-547.9086;Inherit;False;Property;_FoamThickness;Foam Thickness;6;0;Create;True;0;0;False;0;False;0;0.58;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;64;-1033.593,-60.6202;Inherit;False;1084.594;658.2341;Refraction;6;57;58;55;60;61;115;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BreakToComponentsNode;48;-2221.719,-781.9655;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DepthFade;46;-2117.142,-1056.071;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;44;-1553.466,-89.80299;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;False;0;False;-1;None;26efba371a1e33d4bae6d584349af890;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;72;-1555.87,-976.1925;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;19;-1227.894,820.3406;Inherit;True;Global;_GlobalEffectRT;_GlobalEffectRT;1;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;70;-1909.137,-566.2523;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;-1053.328,1183.949;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-983.5933,481.6139;Inherit;False;Property;_RrefractionDistortion;Rrefraction Distortion;7;0;Create;True;0;0;False;0;False;0;0.6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;74;-1558.111,-1074.332;Inherit;False;Property;_Depthoffsetcoloring;Depth offset coloring;10;0;Create;True;0;0;False;0;False;0;1.65;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;77;-963.774,-1646.225;Inherit;False;534.0222;597.757;Depth Colors;4;66;67;69;76;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GrabScreenPosition;115;-930.0789,204.6777;Inherit;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;71;-1716.446,-715.4934;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-709.2308,421.9937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-823.0125,1058.326;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-1192.753,-1121.265;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-650.6107,842.4706;Inherit;False;Property;_RippleCutoff;Ripple Cutoff;0;0;Create;True;0;0;False;0;False;0;0.63;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;-1066.692,-546.131;Inherit;False;906.4694;385.9865;Foam Line With Noise and Cutoff;6;54;78;79;80;82;81;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;66;-913.774,-1596.225;Inherit;False;Property;_EdgeColor;Edge Color;8;0;Create;True;0;0;False;0;False;0,0,0,0;0.1058203,0.7208415,0.7735849,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;92;-1127.285,-575.2742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;21;-449.4536,966.2377;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;55;-529.246,255.1194;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WireNode;93;-1174.62,-712.0212;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;76;-880.7012,-1184.489;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;52;-1514.327,-798.4658;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;67;-909.9226,-1410.145;Inherit;False;Property;_DepthColor;Depth Color;9;0;Create;True;0;0;False;0;False;0,0,0,0;0.04939453,0.07178129,0.6981132,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;61;-876.6829,-21.14302;Inherit;True;Global;_CameraOpaqueTexture;_CameraOpaqueTexture;11;0;Create;True;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SmoothstepOpNode;22;-205.9365,938.6817;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-1016.692,-424.6966;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-904.3229,-276.1447;Inherit;False;Property;_FoamCutoffSoftness;Foam Cutoff Softness;13;0;Create;True;0;0;False;0;False;0;0.11;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;60;-268.9991,200.7363;Inherit;True;Property;_TextureSample2;Texture Sample 2;8;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-845.8229,-377.5446;Inherit;False;Property;_FoamCutoff;Foam Cutoff;12;0;Create;True;0;0;False;0;False;0;0.9;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;69;-611.7519,-1207.468;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;83;-406.9922,-778.2088;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;89.20201,-920.3804;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-615.4401,-318.6061;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;85;429.4504,365.1895;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-811.2367,-496.131;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;94;642.8097,-770.683;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;80;-349.2223,-445.1446;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;99;1554.352,-558.3271;Inherit;False;531.4287;687.1947;Main Tint;3;98;101;97;;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;105;92.74467,-233.86;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;95;964.3208,-614.4598;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;1162.932,-515.2396;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;98;1579.162,-194.3351;Inherit;True;Property;_MainText;Main Text;14;0;Create;True;0;0;False;0;False;-1;None;622bf5fbcdd425842ab0c445fa04cb0f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;104;314.9695,715.6458;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;1083.872,821.0867;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;1946.452,-508.3272;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;101;1609.056,-411.1987;Inherit;False;Property;_Tint;Tint;15;0;Create;True;0;0;False;0;False;0,0,0,0;0.349991,0.5363007,0.6132076,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;102;2228.728,-506.9205;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PosVertexDataNode;29;-3702.472,14.74488;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;106;1411.253,693.8256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;47;-2573.289,-865.7593;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;113;2628.235,-365.8314;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/WaterRefractionShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;30;0;25;0
WireConnection;30;1;114;0
WireConnection;31;0;30;0
WireConnection;37;0;31;0
WireConnection;37;2;31;2
WireConnection;34;0;35;0
WireConnection;34;1;33;0
WireConnection;36;0;37;0
WireConnection;36;1;34;0
WireConnection;38;1;36;0
WireConnection;40;0;37;0
WireConnection;40;1;38;1
WireConnection;7;0;28;1
WireConnection;7;2;28;3
WireConnection;12;0;3;1
WireConnection;12;2;3;3
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;14;0;2;0
WireConnection;14;1;15;0
WireConnection;11;0;7;0
WireConnection;11;1;12;0
WireConnection;43;0;37;0
WireConnection;43;2;41;0
WireConnection;13;0;11;0
WireConnection;13;1;14;0
WireConnection;48;0;116;0
WireConnection;44;1;43;0
WireConnection;72;0;46;0
WireConnection;72;1;48;3
WireConnection;70;0;48;3
WireConnection;70;1;50;0
WireConnection;16;0;13;0
WireConnection;16;1;17;0
WireConnection;71;0;46;0
WireConnection;71;1;70;0
WireConnection;57;0;44;1
WireConnection;57;1;58;0
WireConnection;18;0;19;0
WireConnection;18;1;16;0
WireConnection;73;0;74;0
WireConnection;73;1;72;0
WireConnection;92;0;44;1
WireConnection;21;0;20;0
WireConnection;21;1;18;3
WireConnection;55;0;115;0
WireConnection;55;2;57;0
WireConnection;93;0;71;0
WireConnection;76;0;73;0
WireConnection;52;0;71;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;22;2;18;3
WireConnection;54;0;52;0
WireConnection;54;1;44;1
WireConnection;60;0;61;0
WireConnection;60;1;55;0
WireConnection;69;0;66;0
WireConnection;69;1;67;0
WireConnection;69;2;76;0
WireConnection;83;0;93;0
WireConnection;83;1;92;0
WireConnection;87;0;69;0
WireConnection;87;1;83;0
WireConnection;79;0;82;0
WireConnection;79;1;81;0
WireConnection;85;0;60;0
WireConnection;85;1;22;0
WireConnection;78;0;52;0
WireConnection;78;1;54;0
WireConnection;94;0;85;0
WireConnection;94;1;87;0
WireConnection;80;0;82;0
WireConnection;80;1;79;0
WireConnection;80;2;78;0
WireConnection;105;0;80;0
WireConnection;95;0;85;0
WireConnection;95;1;94;0
WireConnection;96;0;80;0
WireConnection;96;1;95;0
WireConnection;104;0;105;0
WireConnection;103;0;104;0
WireConnection;103;1;22;0
WireConnection;97;0;96;0
WireConnection;97;1;98;0
WireConnection;102;0;97;0
WireConnection;106;0;103;0
WireConnection;113;0;102;0
WireConnection;113;2;106;0
WireConnection;113;4;44;1
ASEEND*/
//CHKSM=1A6550E83867276039531B36D3F04F458EE9D3F8