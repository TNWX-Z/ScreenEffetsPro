using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class WaterColor : MonoBehaviour {

    [SerializeField]
    private Material mat_WaterColor;



    void OnRenderImage(RenderTexture src,RenderTexture dst)
    {
        if (mat_WaterColor == null)
        {
            Graphics.Blit(src, dst);
            return;
        }
        Graphics.Blit(src, dst, mat_WaterColor, -1);
    }

}
