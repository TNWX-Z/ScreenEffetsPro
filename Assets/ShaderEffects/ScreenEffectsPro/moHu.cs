using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class moHu : MonoBehaviour {

    [SerializeField]
    private Material mat_BackGround;
    [SerializeField]
    private Material mat_moHu;

	void Start () {

    }
	void Update () {
		
	}
    RenderTexture tmp_rt = null;

    void OnRenderImage(RenderTexture src,RenderTexture dst)
    {
        if (mat_moHu == null || mat_BackGround == null)
        {
            Graphics.Blit(src, dst);
            return;
        }
        if (tmp_rt == null)
        {
            tmp_rt = new RenderTexture(src.width, src.height, 0, src.format, RenderTextureReadWrite.Default);
        }
        
        Graphics.Blit(src, tmp_rt, mat_BackGround, -1);
        mat_moHu.SetTexture("_Tex", tmp_rt);
        Graphics.Blit(tmp_rt, dst, mat_moHu, -1);
    }
}
