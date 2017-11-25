using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RainDropScreen : MonoBehaviour {

    [SerializeField]
    private Material m_mat_RainDopScreen;

	void Start () {
	    	
	}
	
	void Update () {
		
	}

    void OnRenderImage(RenderTexture src,RenderTexture dst)
    {
        if (m_mat_RainDopScreen == null)
        {
            Graphics.Blit(src, dst);
            return;
        }

        Graphics.Blit(src, dst, m_mat_RainDopScreen, 0);

    }
}
