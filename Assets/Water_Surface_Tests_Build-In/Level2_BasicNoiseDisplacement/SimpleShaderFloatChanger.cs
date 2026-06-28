using UnityEngine;

public class SimpleShaderFloatChanger : MonoBehaviour
{
    public Material material;
    public string floatName = "_NoiseScale"; // 0.1 .. 10

    public float minValue = 0.5f;
    public float maxValue = 3.5f;
    public void OnChangeFloat(float floatValue)
    {
        material.SetFloat(floatName, Mathf.Lerp(minValue, maxValue, floatValue));
    }
}
