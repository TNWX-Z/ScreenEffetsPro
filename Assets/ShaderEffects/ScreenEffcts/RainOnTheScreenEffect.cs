using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RainOnTheScreenEffect : MonoBehaviour {

    [SerializeField]
    private Material mat_RainOnTheScreen;
	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    void OnRenderImage(RenderTexture src,RenderTexture dst)
    {
        if (!this.mat_RainOnTheScreen)
        {
            Graphics.Blit(src,dst);
            return;
        }
        this.mat_RainOnTheScreen.SetTexture("_MainTex", src);
        Graphics.Blit(src,dst,this.mat_RainOnTheScreen,-1);
    }


}
