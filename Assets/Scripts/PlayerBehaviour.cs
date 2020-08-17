using UnityEngine;

public class PlayerBehaviour : MonoBehaviour
{
    public GameObject bullet;
    public Transform shootPoint;
    public float shakeForce;
    public float shakeTime;

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Mouse0))
        {
            Attack();
        }
    }

    private void Attack()
    {
        Instantiate(bullet, shootPoint.position, shootPoint.rotation);
        Shake.instance.ShakeCamera(shakeForce, shakeTime);
    }
}