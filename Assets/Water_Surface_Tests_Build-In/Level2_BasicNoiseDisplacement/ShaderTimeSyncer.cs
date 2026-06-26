// this simple script used as a replecement of a shader's build _Time.y to fix shadows cast issues
using UnityEngine;

[ExecuteInEditMode]
public class ShaderTimeSyncer : MonoBehaviour
{
    private Material meshMaterial;
    private float timer = 0f;

    void Start()
    {
        var renderer = GetComponent<MeshRenderer>();
        if (renderer != null) meshMaterial = renderer.sharedMaterial;
    }

    void Update()
    {
        if (meshMaterial == null) return;

        if (Application.isPlaying)
        {
            timer += Time.deltaTime;
        }
        else
        {
            timer = (float)Time.realtimeSinceStartup;
        }

        meshMaterial.SetFloat("_CustomTime", timer);
    }
}