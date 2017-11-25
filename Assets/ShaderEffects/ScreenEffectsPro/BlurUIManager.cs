using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.UI;

[ExecuteInEditMode]
public class BlurUIManager : MonoBehaviour {
    [Header("设置Hash模糊参数")]

    [SerializeField]
    private Slider m_blur_Count;
    [Range(1f, 64f)]
    public float f_blur_Count;
    [SerializeField]
    private Slider m_blur_Radius;
    [Range(-0.2f, 0.2f)]
    public float f_blur_Radius;
    [SerializeField]
    private Slider m_blur_Min;
    [Range(0f, 1f)]
    public float f_blur_Min;
    [SerializeField]
    private Slider m_blur_Max;
    [Range(0f, 1f)]
    public float f_blur_Max;

    [Space(10)]
    [Header("后期混合调色")]
    public Color m_color_blur;
    [Space(10)]
    [Header("毛玻璃颜色")]
    public Color m_color_glass;
    [Space(10)]
    [Header("初始化")]
    [SerializeField]
    private Material m_mat_Blur;

    private Image m_img_Self;
    void Awake()
    {

    }
    void Start()
    {
        m_img_Self = GetComponent<Image>();//.color = this.m_blur_color;
    }
    void Update()
    {
        m_img_Self.color = this.m_color_blur;
        this.m_mat_Blur.SetColor("_GlassColor", m_color_glass);
    }
    public void OnBlurCountSlider()
    {
        this.m_mat_Blur.SetFloat("_Kernel", m_blur_Count.value);
        f_blur_Count = m_blur_Count.value;
    }
    public void OnBlurRadiusSlider()
    {
        this.m_mat_Blur.SetFloat("_BlurRadius", m_blur_Radius.value);
        f_blur_Radius = m_blur_Radius.value;
    }
    public void OnBlurMin()
    {
        this.m_mat_Blur.SetFloat("_minBlur", m_blur_Min.value);
        f_blur_Min = m_blur_Min.value;
    }
    public void OnBlurMax()
    {
        this.m_mat_Blur.SetFloat("_maxBlur", m_blur_Max.value);
        f_blur_Max = m_blur_Max.value;
    }
}