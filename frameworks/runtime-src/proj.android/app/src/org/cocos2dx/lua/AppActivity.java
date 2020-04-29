/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.
Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import android.os.Bundle;
import android.content.Intent;
import android.net.Uri;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.view.View;
import android.provider.MediaStore;
import org.cocos2dx.lib.Cocos2dxActivity;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class AppActivity extends Cocos2dxActivity{
    static AppActivity  instance;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.setEnableVirtualButton(false);
        super.onCreate(savedInstanceState);
        // Workaround in https://stackoverflow.com/questions/16283079/re-launch-of-activity-on-home-button-but-only-the-first-time/16447508
        if (!isTaskRoot()) {
            // Android launched another instance of the root activity into an existing task
            //  so just quietly finish and go away, dropping the user back into the activity
            //  at the top of the stack (ie: the last state of this task)
            // Don't need to finish it again since it's finished in super.onCreate .
            return;
        }

        // DO OTHER INITIALIZATION BELOW
        
        instance = this;
    }

    public static String getSDCardDocPath()
    {
        File file = instance.getExternalFilesDir(null);
        if (null != file){
            return file.getPath();
        }

        return instance.getFilesDir().getAbsolutePath();
    }
        
    //install apk
    public static void installClient(String apkPath)
    {       
        if(!"".equals(apkPath))
        {
            File apkFile = new File(apkPath);
            if (null != apkFile && apkFile.exists()) 
            {
                Intent installIntent = new Intent(Intent.ACTION_VIEW);
                installIntent.setDataAndType(Uri.fromFile(apkFile), "application/vnd.android.package-archive");
                instance.startActivity(installIntent);
            }
        }
    }
    
    //自动启动
    public static void restart()
    {
        instance.restartApp();
    }
    public void restartApp()
    {
        finish();
        Intent i = getBaseContext().getPackageManager().getLaunchIntentForPackage(getBaseContext().getPackageName());  
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);  
        startActivity(i);
        android.os.Process.killProcess(android.os.Process.myPid());
    }
    public static Intent getCsvFileIntent(String Path)  
    {  
        File file = new File(Path);
        Intent intent = new Intent("android.intent.action.VIEW");  
        intent.addCategory("android.intent.category.DEFAULT");  
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);  
        Uri uri = Uri.fromFile(file);  
        intent.setDataAndType(uri, "text/csv");  
        return intent;  
    }

    // 获取指定Activity的截屏，保存到png文件
    public static Bitmap takeScreenShot(AppActivity activity) {
        // View是你需要截图的View
        View view = activity.getWindow().getDecorView();
        view.setDrawingCacheEnabled(true);
        view.buildDrawingCache();
        Bitmap b1 = view.getDrawingCache();
 
        // 获取状态栏高度
        Rect frame = new Rect();
        activity.getWindow().getDecorView().getWindowVisibleDisplayFrame(frame);
        int statusBarHeight = frame.top;
 
        // 获取屏幕长和高
        int width = activity.getWindowManager().getDefaultDisplay().getWidth();
        int height = activity.getWindowManager().getDefaultDisplay()
                .getHeight();
        // 去掉标题栏
        // Bitmap b = Bitmap.createBitmap(b1, 0, 25, 320, 455);
        Bitmap b = Bitmap.createBitmap(b1, 0, statusBarHeight, width, height
                - statusBarHeight);
        view.destroyDrawingCache();
        return b;
    }
 
    // 保存到sdcard
    public static void savePic(Bitmap b, String strFileName) {
        FileOutputStream fos = null;
        try {
            fos = new FileOutputStream(strFileName);
            if (null != fos) {
                b.compress(Bitmap.CompressFormat.PNG, 90, fos);
                fos.flush();
                fos.close();
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    //保存图片到系统相册
    public static boolean saveImgToSystemGallery(final String path, final String filename)
    {
        boolean bRes = false;
        // 文件插入系统图库
        try 
        {
            MediaStore.Images.Media.insertImage(instance.getContentResolver(), path, filename, null);
            // 最后通知图库更新
            instance.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + path)));
            bRes = true;
        } 
        catch (FileNotFoundException e) 
        {
            e.printStackTrace();
        }
        return bRes;
    }
 
    // 程序入口
    public static void shoot(final String path, final String filename) {
        savePic(takeScreenShot(instance), path + filename);
        // 最后通知图库更新
        instance.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.parse("file://" + path)));

        Intent intent  = new Intent(Intent.ACTION_SEND);
        File file = new File(path + filename);
        intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(file));
        intent.setType("image/jpeg");
        Intent chooser = Intent.createChooser(intent, "Share screen shot");
        if(intent.resolveActivity(instance.getPackageManager()) != null){
            instance.startActivity(chooser);
        }
    }
}
