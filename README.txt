##################################
	SJ_RimLight ver3.0beta
###################################



非常感谢您使用我的MME【屏幕空间等宽边缘光】！

【一、前言】
首先在开头贴上我所查阅的参考文案，基本思路即按照下述专栏构成，感谢大佬们的研究与分享！

《Unity URP Shader 与 HLSL 自学笔记六 等宽屏幕空间边缘光》 作者：Cutano
https://zhuanlan.zhihu.com/p/365339160

《屏幕空间等距边缘光》 作者：馬鹿家郎
https://www.bilibili.com/read/cv11841147

为了用于MMD，有部分采用了自己的思路。最后思路大致为获取人物模型的深度图，视角法线图，剪影图等，然后利用前三者生成偏移剪影图再进行对比获取边缘。

这种边缘光相对人物等宽，且可以被遮挡。

【二、使用方法】
step1
	载入【SJ_RimLight.x】文件至MMD中。
	载入控制器【SJ_RimLight_Control.pmx】,同时在控制器中载入【SJ_RimLight_Control_Default.vmd】的预设配置动作文件。
	
step2
	打开MMEffect面板：
	在【SJ_RimDepth】面板中###只给###需要边缘光的 人物模型 赋予【SJ_RimDepth】文件夹中的【RimDepth.fx】描画文件。

	#请注意通常情况下，此面板不给场景模型赋予文件。

step3
	打开MMEffect面板：
	在【SJ_RimMask】面板中给需要边缘光的 人物模型 赋予【SJ_RimMask】文件夹中的【On.fx】遮罩描画文件。
	给不需要边缘光的 场景模型/人物材质 赋予【off.fx】遮罩描画文件。

	#额外的，你可以复制重命名一份【On.fx】文件，编辑文件中开头的参数来改变某一个材质的边缘光强度和宽度。
	#用上述方法已经复制了一份【On_Tr=0.5.fx】,例如感觉皮肤上的边缘光太亮了，则可以将这个描画文件赋给皮肤材质。
	#【On_NoBlock.fx】代表没有内侧边缘光，也是用上面的方法改变的。
	
step4
	现在你可以调整控制器中的参数了！

[控制器参数说明]
[骨骼][Light_Pos]:旋转他可以在三维层面控制边缘光的方向，如果需要使用请先将[表情][PhongMask_On]拉到高于0.5的值。
[骨骼][RGB_Color]:这个骨骼的XYZ位置对应着RGB值，他们的取值范围都在 0-10 之间。

[表情左上][X_Size]:在二维层面改变X方向上的边缘光宽度。
[表情左上][X_Direction]:在二维层面改变X方向上的边缘光方向/左右分布。
[表情左上][X_Intensity]:在二维层面改变X方向上的边缘光强度分布。

[表情右上][Y_Size]:在二维层面改变Y方向上的边缘光宽度。
[表情右上][Y_Direction]:在二维层面改变Y方向上的边缘光方向/上下分布。
[表情右上][Y_Intensity]:在二维层面改变Y方向上的边缘光强度分布。

[表情左下][Edge_Intensity]:外侧边缘光的亮度。
[表情左下][Block_Intensity]:内侧边缘光的亮度。
[表情左下][Block_Cut]:内侧边缘光亮度数值裁剪。
[表情左下][Block_Power]:内侧边缘光亮度数值指数运算。

[表情右下][PhongMask_On]:这项高于0.5时，启用三维层面控制边缘光的方向的功能，旋转[骨骼][Light_Pos]以调整方向。
[表情右下][RimLight_Debug]:这项时我自己debug使用的，在这边给出所有debug数值：
				0.0 : 正常画面
				(0.0,0.1] : 视角法线X轴
				(0.1,0.2] : 视角法线Y轴
				(0.2,0.3] : 深度信息
				(0.3,0.4] : 模型剪影信息
				(0.4,0.5] : 外侧边缘光遮罩信息
				(0.5,0.6] : 内侧边缘光遮罩信息
				(0.6,0.7] : PhongMask遮罩信息
				(0.7,0.8] : 外侧边缘光范围
				(0.8,0.9] : 内侧边缘光范围
				(0.9,1.0] : 计算强度与颜色后的边缘光
				(1.0,1.1] : 边缘光宽度信息


【三、使用规约】
1.允许二次配布和传递，但前提是将完整的带ReadMe的原压缩包进行传递，并告知对方注明借物表。
2.如果您对本MME进行了优化修改，请在征得本人允许情况下配布，且配布时必须包含这份借物表并要求完整填写借物表。
###################
3.任何形式的，使用本MME之后，必须在借物表的显眼处标注我的名字“三金络合物”。
###################
4.本人(三金络合物)拥有最终解释权。

【四、联系方式】
bilibili@三金络合物
uid：1223127584
QQ：3371741288 / 467440249


2023.04.21
